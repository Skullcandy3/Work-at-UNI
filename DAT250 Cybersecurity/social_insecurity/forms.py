"""Provides all forms used in the Social Insecurity application.

This file is used to define all forms used in the application.
It is imported by the social_insecurity package.

Example:
    from flask import Flask
    from app.forms import LoginForm

    app = Flask(__name__)

    # Use the form
    form = LoginForm()
    if form.validate_on_submit() and form.login.submit.data:
        username = form.username.data
"""

from datetime import datetime
from typing import cast

from flask_wtf import FlaskForm
from flask_wtf.file import FileAllowed, FileSize
from wtforms.validators import DataRequired, Length, EqualTo, Regexp
from wtforms import (
    BooleanField,
    DateField,
    FileField,
    FormField,
    PasswordField,
    StringField,
    SubmitField,
    TextAreaField,
)

# Defines all forms in the application, these will be instantiated by the template,
# and the routes.py will read the values of the fields
# TODO: Add validation, maybe use wtforms.validators??
# TODO: There was some important security feature that wtforms provides, but I don't remember what; implement it
from wtforms.validators import (
    DataRequired,  #ensures that data is inserted
    Length,  #Use this to take the length of some provided user inputs
    ValidationError,  #This ensures that an error is displayed
)

# Configuration constants for limits
max_post_length = 280 #based on X-post limitations
max_comment_length = 150 #Based on tiktok 

max_username_length = 25
min_username_length = 8

max_password_length = 20
min_password_length = 8

max_file_size = 5 * 1024 * 1024  # 5MB in bytes
allowed_extensions = {'png', 'jpg', 'jpeg'}

def validate_not_empty(form, field):
    """Custom validator to ensure field is not empty or just whitespace."""
    
    if not field.data or not field.data.strip():
        raise ValidationError("This field cannot be empty or contain only whitespace")


class LoginForm(FlaskForm):
    """Provides the login form for the application."""

    username = StringField(
        label="Username",
        validators=[
            DataRequired(),
            Length(min=3, max=30),
            Regexp(r'^[a-zA-Z0-9_]+$', message="Username must contain only letters, numbers, and underscores.")
        ],
        render_kw={"placeholder": "Username"}
    )
    password = PasswordField(
        label="Password",
        validators=[
            DataRequired(),
            Length(min=6, max=128)
        ],
        render_kw={"placeholder": "Password"}
    )
    remember_me = BooleanField(label="Remember me")
    submit = SubmitField(label="Sign In")


class RegisterForm(FlaskForm):
    """Provides the registration form for the application."""

    first_name = StringField(
        label="First Name",
        validators=[
            DataRequired(),
            Length(min=1, max=50),
            Regexp(r'^[a-zA-Z\-]+$', message="First name must contain only letters and hyphens.")
        ],
        render_kw={"placeholder": "First Name"}
    )
    last_name = StringField(
        label="Last Name",
        validators=[
            DataRequired(),
            Length(min=1, max=50),
            Regexp(r'^[a-zA-Z\-]+$', message="Last name must contain only letters and hyphens.")
        ],
        render_kw={"placeholder": "Last Name"}
    )
    username = StringField(
        label="Username",
        validators=[
            DataRequired(),
            Length(min=3, max=30),
            Regexp(r'^[a-zA-Z0-9_]+$', message="Username must contain only letters, numbers, and underscores.")
        ],
        render_kw={"placeholder": "Username"}
    )
    password = PasswordField(
        label="Password",
        validators=[
            DataRequired(),
            Length(min=6, max=128)
        ],
        render_kw={"placeholder": "Password"}
    )
    confirm_password = PasswordField(
        label="Confirm Password",
        validators=[
            DataRequired(),
            EqualTo('password', message="Passwords must match.")
        ],
        render_kw={"placeholder": "Confirm Password"}
    )
    submit = SubmitField(label="Sign Up")



class IndexForm(FlaskForm):
    """Provides the composite form for the index page."""

    login = cast(LoginForm, FormField(LoginForm))
    register = cast(RegisterForm, FormField(RegisterForm))


class PostForm(FlaskForm):
    """Provides the post form for the application."""

    content = TextAreaField(
        label="New Post",
        render_kw={"placeholder": "What are you thinking about?"},
        validators=[
            DataRequired(message="Post content cannot be empty"), validate_not_empty, Length(min=1, max=max_post_length, message=f"Post must be between 1 and {max_post_length} characters")])
    image = FileField(
        label="Image",
        validators=[FileAllowed(list(allowed_extensions), message=f"Only {', '.join(allowed_extensions)} files are allowed"), FileSize(max_size=max_file_size, message=f"File size must be less than {max_file_size // (1024 * 1024)}MB")])
    submit = SubmitField(label="Post")


class CommentsForm(FlaskForm):
    """Provides the comment form for the application."""

    comment = TextAreaField(
        label="New Comment",
        render_kw={"placeholder": "What do you have to say?"},
        validators=[
            DataRequired(),
            validate_not_empty,
            Length(min=1, max=max_comment_length)])
    submit = SubmitField(label="Comment")



class FriendsForm(FlaskForm):
    """Provides the friend form for the application."""

    username = StringField(label="Friend's username", render_kw={"placeholder": "Username"})
    submit = SubmitField(label="Add Friend")


class ProfileForm(FlaskForm):
    """Provides the profile form for the application."""

    education = StringField(label="Education", render_kw={"placeholder": "Highest education"})
    employment = StringField(label="Employment", render_kw={"placeholder": "Current employment"})
    music = StringField(label="Favorite song", render_kw={"placeholder": "Favorite song"})
    movie = StringField(label="Favorite movie", render_kw={"placeholder": "Favorite movie"})
    nationality = StringField(label="Nationality", render_kw={"placeholder": "Your nationality"})
    birthday = DateField(label="Birthday", default=datetime.now())
    submit = SubmitField(label="Update Profile")
