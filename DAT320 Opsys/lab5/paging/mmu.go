package paging

// MMU is the structure for the simulated memory management unit.
type MMU struct {
	frames    [][]byte           // contains memory content in form of frames[frameIndex][offset]
	freeList                     // tracks free physical frames
	processes map[int]*PageTable // contains page table for each process (key=pid)
	frameSize int
}

// OffsetLookupTable gives the bit mask corresponding to a virtual address's offset of length n,
// where n is the table index. This table can be used to find the offset mask needed to extract
// the offset from a virtual address. It supports up to 32-bit wide offset masks.
//
// OffsetLookupTable[0] --> 0000 ... 0000
// OffsetLookupTable[1] --> 0000 ... 0001
// OffsetLookupTable[2] --> 0000 ... 0011
// OffsetLookupTable[3] --> 0000 ... 0111
// OffsetLookupTable[8] --> 0000 ... 1111 1111
// etc.
var OffsetLookupTable = []int{
	// 0000, 0001, 0011, 0111, 1111, etc.
	0x0000000, 0x00000001, 0x00000003, 0x00000007,
	0x000000f, 0x0000001f, 0x0000003f, 0x0000007f,
	0x00000ff, 0x000001ff, 0x000003ff, 0x000007ff,
	0x0000fff, 0x00001fff, 0x00003fff, 0x00007fff,
	0x000ffff, 0x0001ffff, 0x0003ffff, 0x0007ffff,
	0x00fffff, 0x001fffff, 0x003fffff, 0x007fffff,
	0x0ffffff, 0x01ffffff, 0x03ffffff, 0x07ffffff,
	0xfffffff, 0x1fffffff, 0x3fffffff, 0x7fffffff, 0xffffffff,
}

// NewMMU creates a new MMU with a memory of memSize bytes.
// memSize should be >= 1 and a multiple of frameSize.
func NewMMU(memSize, frameSize int) *MMU {
	numFrames := memSize / frameSize
	frames := make([][]byte, numFrames)
	for i := range frames {
		frames[i] = make([]byte, frameSize) // initialize each frame with zeroed bytes
	}

	return &MMU{
		frames:    frames,
		freeList:  newFreeList(numFrames),
		processes: make(map[int]*PageTable),
		frameSize: frameSize,
	}
}

// Alloc allocates n bytes of memory for process pid.
// The allocated memory is added to the process's page table.
// The process is given a page table if it doesn't already have one,
// unless an out of memory error occurred.
// Suggested approach:
// - calculate #frames needed to allocate n bytes, error if not enough free frames
// - if process pid has no page table, create one for it
// - determine which frames to allocate to the process
// - add the frames to the process's (identified by pid) page table and
// - update the free list
func (mmu *MMU) Alloc(pid, n int) error {
	if n <= 0 {
		return errNothingToAllocate
	}

	framesNeeded := (n + mmu.frameSize - 1) / mmu.frameSize

	// Try to find free frames
	allocatedFrames, err := mmu.freeList.findFreeFrames(framesNeeded)
	if err != nil {
		return err
	}

	// Create page table if it doesn't exist
	if mmu.processes[pid] == nil {
		mmu.processes[pid] = &PageTable{frameIndices: []int{}}
	}

	// Remove frames from free list
	err = mmu.freeList.removeFrames(allocatedFrames)
	if err != nil {
		return err
	}

	// Append frames to the process's page table
	mmu.processes[pid].Append(allocatedFrames)

	return nil
}

// Write writes content to the given process's address space starting at virtualAddress.
// Suggested approach:
// Step 1
// - check valid pid (must have a page table)
// - translate the virtual address
// Step 2
// - check if the memory must be extended in order to write the content
//   from the given starting address
// Step 3
// - attempt to allocate more memory if necessary to complete the write
// Step 4
// - sequentially write content into the known-to-be-valid address space
func (mmu *MMU) Write(pid, virtualAddress int, content []byte) error {
	// Basic check to make sure errors are chaught!
	if len(content) == 0 {
		return errNothingToAllocate
	}

	// Step 1: Check if process exists
	pt, ok := mmu.processes[pid]
	if !ok {
		return errInvalidProcess
	}

	frameSize := mmu.frameSize
	offsetBits := log2(frameSize)

	// Step 2: Calculate how many pages are needed to write the content
	startVPN, startOffset := extract(virtualAddress, offsetBits)
	endAddress := virtualAddress + len(content) - 1
	endVPN, _ := extract(endAddress, offsetBits)

	// Step 3: Allocate more memory if needed
	if endVPN >= pt.Len() {
		pagesToAlloc := endVPN - pt.Len() + 1
		err := mmu.Alloc(pid, pagesToAlloc*frameSize)
		if err != nil {
			return err
		}
	}

	// Step 4: Write content across pages
	bytesWritten := 0
	for vpn := startVPN; vpn <= endVPN; vpn++ {
		frameIndex, err := pt.Lookup(vpn)
		if err != nil {
			return err
		}
		frame := mmu.frames[frameIndex]

		var writeStart int
		if vpn == startVPN {
			writeStart = startOffset
		} else {
			writeStart = 0
		}

		writeEnd := frameSize
		if vpn == endVPN {
			writeEnd = ((virtualAddress+len(content))-1)&((1<<offsetBits)-1) + 1
		}

		toWrite := writeEnd - writeStart
		copy(frame[writeStart:writeEnd], content[bytesWritten:bytesWritten+toWrite])
		bytesWritten += toWrite
	}

	return nil

}

// Read returns content of size n bytes from the given process's address space starting at virtualAddress.
// Suggested approach:
// Step 1
// - check valid pid (must have a page table)
// Step 2 and 3
// - translate the virtual address
// - (optional) determine if it's possible to read the requested number
//   of bytes before starting to read the memory content
// Step 4 and 5
// - read and return the requested memory content
func (mmu *MMU) Read(pid, virtualAddress, n int) ([]byte, error) {
	// Basic check again here
	if n <= 0 {
		return nil, errNothingToRead
	}

	// Step 1: Check if process exists
	pt, ok := mmu.processes[pid]
	if !ok {
		return nil, errInvalidProcess
	}

	frameSize := mmu.frameSize
	offsetBits := log2(frameSize)

	// Step 2: Extract start VPN and offset
	startVPN, startOffset := extract(virtualAddress, offsetBits)

	// Step 3: Calculate end VPN
	endAddress := virtualAddress + n - 1
	endVPN, _ := extract(endAddress, offsetBits)

	// Step 4: Ensure all pages are allocated
	if endVPN >= pt.Len() {
		return nil, errAddressOutOfBounds
	}

	// Step 5: Read across pages
	content := make([]byte, 0, n)
	bytesRead := 0

	for vpn := startVPN; vpn <= endVPN; vpn++ {
		frameIndex, err := pt.Lookup(vpn)
		if err != nil {
			return nil, err
		}
		frame := mmu.frames[frameIndex]

		var readStart int
		if vpn == startVPN {
			readStart = startOffset
		} else {
			readStart = 0
		}

		readEnd := frameSize
		if vpn == endVPN {
			readEnd = ((virtualAddress+n)-1)&((1<<offsetBits)-1) + 1
		}

		toRead := readEnd - readStart
		content = append(content, frame[readStart:readEnd]...)
		bytesRead += toRead
	}

	return content, nil
}

// Free is called by a process's Free() function to free some of its allocated memory.
// Suggested approach:
// Step 1
// - check valid pid (must have a page table)
// Step 2
// - check if there are at least n entries in the page table of pid
// Step 3
// - free n pages
// Step 4
// - set all the bytes in the freed memory to the value 0
// Step 5
// - re-add the freed frames to the free list
// More clean coding like this! ;)
func (mmu *MMU) Free(pid, n int) error {
	// Basic check again
	if n <= 0 {
		return errNothingToAllocate
	}

	// Step 1: Check if process exists
	pt, ok := mmu.processes[pid]
	if !ok {
		return errInvalidProcess
	}

	// Step 2: Check if enough pages are allocated
	if n > pt.Len() {
		return errFreeOutOfBounds
	}

	// Step 3: Remove last n pages from the page table
	freedFrames, err := pt.Free(n)
	if err != nil {
		return err
	}

	// Step 4: Zero out the memory in the freed frames
	for _, frameIndex := range freedFrames {
		frame := mmu.frames[frameIndex]
		for i := range frame {
			frame[i] = 0
		}
	}

	// Step 5: Return frames to the free list
	err = mmu.freeList.addFrames(freedFrames)
	if err != nil {
		return err
	}

	return nil
}

// extract returns the virtual page number and offset for the given virtual address,
// and the number of bits in the offset n.
// the Virtual Addresses section of the README.
// The procedure is described in detail in Chapter 18.1 of the textbook.
// HINT: It can be solved quite easily with bitwise operators.
// (see https://golang.org/ref/spec#Arithmetic_operators ).
// You might also find the provided log2 function and the OffsetLookupTable
// table useful for this purpose.
func extract(virtualAddress, n int) (vpn, offset int) {
	offsetMask := (1 << n) - 1
	offset = virtualAddress & offsetMask
	vpn = virtualAddress >> n
	return vpn, offset
}

// translateAndCheck returns the virtual page number and offset for the given virtual address.
// If the virtual address is invalid for process pid, an error is returned.
// The procedure is described in detail in Chapter 18.1 of the textbook.
// It is expected that this method calls the extract function above
// to compute the VPN and offset to be returned from this function after
// checking that the process has access to the returned VPN.
// You might also find the provided log2 function useful to calculate one
// of the inputs to the extract function.
func (mmu *MMU) translateAndCheck(pid, virtualAddress int) (vpn, offset int, err error) {
	pt, ok := mmu.processes[pid]
	if !ok {
		return 0, 0, errInvalidProcess
	}

	offsetBits := log2(mmu.frameSize)
	vpn, offset = extract(virtualAddress, offsetBits)

	if vpn < 0 || vpn >= pt.Len() {
		return 0, 0, errAddressOutOfBounds
	}

	return vpn, offset, nil
}

// log2 calculates m given n = 2^m.
func log2(n int) int {
	exp := 0
	for {
		if n%2 == 0 && n > 0 {
			exp++
		} else {
			return exp
		}
		n /= 2
	}
}
