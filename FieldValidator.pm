#!/usr/bin/perl

use strict;
use warnings;;

#---------------------------------------------------#
# Author: Ben Schmaus
# Please direct comments, questions,
# and suggestions to perlmods@benschmaus.com
#---------------------------------------------------#

package WWW::FieldValidator;

our $VERSION = "1.05";

# The following constants represent the validator types that can be
# used to validate the specified user input.
use constant WELL_FORMED_EMAIL => 1;
use constant MIN_STR_LENGTH    => 2;
use constant MAX_STR_LENGTH    => 5;
use constant REGEX_MATCH       => 3;
use constant USER_DEFINED_SUB  => 4;

# Create a new Validator object.
sub new {
    my $class  = shift;

    # the type of validation the instance will use
    my $validatorType = shift;

    # the error feedback to return if the
    # test data does not pass validation
    my $feedback = shift;

    my $self = {};

    bless($self, $class);

    $self->{feedback}      = $feedback;
    $self->{validatorType} = $validatorType;

    if ($validatorType == MIN_STR_LENGTH) {

        # set min length to 1 by default
        my $minLength      = shift || 1;
        $self->{minLength} = $minLength;

    } elsif ($validatorType == REGEX_MATCH) {

        my $regex      = shift;
        $self->{regex} = $regex;

    } elsif ($validatorType == USER_DEFINED_SUB) {

        my $subRef   = shift;
        $self->{usub} = $subRef;

    } elsif ($validatorType == MAX_STR_LENGTH) {

        # set max_length to 30 by default
        my $maxLength = shift || 30;
        $self->{maxLength} = $maxLength;
    }

    # is_optional - if true, field is only validated
    # if it's not empty
    my $isOptional      = shift || 0;
    $self->{isOptional} = $isOptional;

    return $self;
}

#----------------------------------------------------#
# These methods should really be treated as private
# because the Form module handles calling these
# methods, for most purposes all you will need to know
# how to do is to instantiate FieldValidators.
#----------------------------------------------------#

# Checks to see what the validation type of the instance is and
# conditionally calls the appropriate validation method.
sub validate {
    my $self  = shift;
    my $input = shift; # user entered data

    # if the field is optional and is empty, don't validate
    return 1 if ($self->{isOptional} && !$input);

    if ($self->{validatorType} == WELL_FORMED_EMAIL) {

        return $self->_validateEmail($input);

    } elsif ($self->{validatorType} == MIN_STR_LENGTH) {

        return $self->_validateStrLength($input, $self->{minLength});

    } elsif ($self->{validatorType} == REGEX_MATCH) {

        return $self->_validateRegex($input, $self->{regex});

    } elsif ($self->{validatorType} == USER_DEFINED_SUB) {

        return $self->{usub}($input);

    } elsif ($self->{validatorType} == MAX_STR_LENGTH) {

        return $self->_validateMaxStrLength($input, $self->{maxLength});
    }
}

sub getFeedback {
    my $self = shift;
    return $self->{feedback};
}

sub get_feedback {
    my $self = shift;
    return $self->getFeedback();
}

# Checks to see if input is a well formed email address.
sub _validateEmail {
    my $self  = shift;
    my $input = shift || '';
    return ($input =~ /^[\w\-\.\+]+@(\w+)(\.([\w\-]+))+$/);
}

# Checks to see if input is a minimum string length.
sub _validateStrLength {
    my $self   = shift;
    my $input  = shift;
    return (length($input) >= $self->{minLength});
}

sub _validateMaxStrLength {
    my $self  = shift;
    my $input = shift;
    return (length($input) <= $self->{maxLength});
}

# Checks to see if input matches the specified pattern.
sub _validateRegex {
    my $self  = shift;
    my $input = shift || '';

    return ($input =~ /$self->{regex}/);
}

1;

__END__

=head1 NAME

WWW::FieldValidator - Provides simple yet robust validation of user entered input

=head1 SYNOPSIS

OO module that is used to validate input.

=head1 DESCRIPTION

This module is used by WWW::Form to perform various validations on input.  This
document covers using the WWW::FieldValidator module as part of a Form object.  In this
case, the only thing you need to know how to do is to instantiate WWW::FieldValidators
properly.  All the validation is handled internally by WWW::Form.

=head2 Function Reference

B<new($validatorType, $errorFeedback, [$minLength, $maxLength, $regex], [$isOptional])>

  Creates a FieldValidator object.  $validatorType is used to determine what type
  of validation will be performed on the input.  The following validator types are
  supported (Note these are constants, the $validatorType param needs to be one of
  the following values):

  WWW::FieldValidator::WELL_FORMED_EMAIL # input must conform to /^[\w\-\.\+]+@(\w+)(\.([\w\-]+))+$/
  WWW::FieldValidator::MIN_STR_LENGTH    # input must be >= a specified string length
  WWW::FieldValidator::MAX_STR_LENGTH    # input must be <= a specified string length
  WWW::FieldValidator::REGEX_MATCH       # input must match a user defined regex
  WWW::FieldValidator::USER_DEFINED_SUB  # input must pass a user defined subroutine's validation

  Examples:

  # create a validator that checks to see if input is a well formed email address
  WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL,
                           'Please make sure you enter a well formed email address');

  # creates a validator that checks to see if input is
  # well formed only if input is not null (or numm string)
  WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL,
                           'Please make sure you enter a well formed email address',
                           $isOptional = 1);

  # creates a validator that checks to see if the input is at least min length
  WWW::FieldValidator->new(WWW::FieldValidator::MIN_STR_LENGTH,
                           'Please make sure you enter something at least 10 characters long',
                           10);

  # creates a validator that checks to see if the input is at least min length
  # only if input is not null or null string
  WWW::FieldValidator->new(WWW::FieldValidator::MIN_STR_LENGTH,
                           'Please make sure you enter something at least 10 characters long',
                           10,
                           1);

  # creates a validator that checks to see if the input is less than max length
  WWW::FieldValidator->new(WWW::FieldValidator::MAX_STR_LENGTH,
                           'Please make sure you enter something less than or equal to 5 characters',
                           5);

  # creates a validator that checks to see if the input is less than max length
  # only if input is not null or null string
  WWW::FieldValidator->new(WWW::FieldValidator::MAX_STR_LENGTH,
                           'Please make sure you enter something less than or equal to 5 characters',
                           5,
                           1);

  # creates a validator that checks to see if the input matches the specified regex
  WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
                           'Please make sure you enter a number',
                           ^\d+$|^\d+\.\d*$|^\d*\.\d+$');

  # creates a validator that checks to see if the input matches the specified regex
  # only if input is not null or null string
  WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
                           'If you are going to enter anything please make sure you enter a number',
                           ^\d+$|^\d+\.\d*$|^\d*\.\d+$',
                           1);


  # creates a validator that checks to see if the input is good according to sub ref
  WWW::FieldValidator->new(WWW::FieldValidator::USER_DEFINED_SUB,
                           'The name you entered already exists',
                           \&is_name_unique);

  # creates a validator that checks to see if the input is good according to sub ref
  # only if input is not null or null string
  WWW::FieldValidator->new(WWW::FieldValidator::USER_DEFINED_SUB,
                           'If you are going to enter a name, you must enter one that does not already exist',
                           \&is_name_unique,
                           1);

  # if you use the validator type: USER_DEFINED_SUB, your subroutine will have access to
  # the value of the form input that your validator is assigned to
  Example:
  sub is_name_unique {
      # gets passed in to this sub for you by way of Form module
      my $name = shift;

      if ($names->{$name}) {
          return 0; # name already exists, input is invalid
      } else {
          return 1;
      }
  }

If you want to use WWW::FieldValidator outside of WWW::Form it's easy to do.  The only
method you need to use is validate.

B<validate($input)>

Returns true if $input passes validation or false otherwise.

  Example:

  my $email_validator = WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL,
                            'Please make sure you enter a well formed email address');

  my $params = $r->param();

  if (my $email = $params->{email}) {

      unless ($email_validator->validate($email)) {
          print $email_validator->getFeedback();
      }
  }

B<getFeedback()>

Returns error feedback for a FieldValidator.  This can also be called as get_feedback().

=head1 SEE ALSO

WWW::Form

=head1 AUTHOR

Ben Schmaus

If you find this module useful or have any suggestions or comments please
send me an email at perlmods@benschmaus.com.

=head1 BUGS

None that I know of, but let me know if you find any.

Send email to perlmods@benschmaus.com

=head1 COPYRIGHT

Copyright 2003, Ben Schmaus.  All Rights Reserved.

This program is free software.  You may copy or redistribute it under
the same terms as Perl itself.  If you find this module useful, please
let me know.

=cut
