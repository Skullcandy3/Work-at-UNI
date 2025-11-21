package slices

import (
	"slices"
	"testing"
)

func TestSort(t *testing.T) {
	tests := []struct {
		input    []int
		expected []int
	}{
		{[]int{5, 3, 8, 6, 2}, []int{2, 3, 5, 6, 8}},
		{[]int{1, 4, 2, 3}, []int{1, 2, 3, 4}},
		{[]int{10, 7, 8, 9}, []int{7, 8, 9, 10}},
		{[]int{3, 1, 4, 2}, []int{1, 2, 3, 4}},
		{[]int{}, []int{}},
	}
	for _, test := range tests {
		slice := make([]int, len(test.input))
		copy(slice, test.input)
		sort(slice)
		if !slices.Equal(slice, test.expected) {
			t.Errorf("Expected %v but got %v", test.expected, slice)
		}
	}
}

func TestUnique(t *testing.T) {
	tests := []struct {
		input    []int
		expected []int
	}{
		{[]int{1, 2, 2, 3}, []int{1, 2, 3}},
		{[]int{4, 4, 4}, []int{4}},
		{[]int{5, 6, 7, 5}, []int{5, 6, 7}},
		{[]int{4, 4, 3, 2, 1, 4}, []int{1, 2, 3, 4}},
		{[]int{}, []int{}},
	}
	for _, test := range tests {
		result := unique(test.input)
		if !slices.Equal(result, test.expected) {
			t.Errorf("Expected %v but got %v", test.expected, result)
		}
	}
}

func TestCombine(t *testing.T) {
	tests := []struct {
		input1   []int
		input2   []int
		expected []int
	}{
		{[]int{1, 2, 3}, []int{4, 2, 5}, []int{1, 2, 3, 4, 5}},
		{[]int{1, 1, 2}, []int{2, 3}, []int{1, 2, 3}},
		{[]int{}, []int{}, []int{}},
		{[]int{7, 8}, []int{6, 9}, []int{6, 7, 8, 9}},
	}
	for _, test := range tests {
		result := combine(test.input1, test.input2)
		if !slices.Equal(result, test.expected) {
			t.Errorf("Expected %v but got %v", test.expected, result)
		}
	}
}
