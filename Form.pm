#!/usr/bin/perl

use strict;
use warnings;

#-------------------------------------------------------------#
# Author:
#   Ben Schmaus
# For more info see:
#   http://intranet.combinenet.com/usr/bschmaus/web_form.html
#-------------------------------------------------------------#

# Form.pm is an object-oriented module that
# should provide a common and easy framework
# for handling HTML forms
package WWW::Form;

our $VERSION = "1.01";

# Constructor for Form class
# creates an instance of a Form object
sub new {
    my $class = shift;

    # hash that contains various bits of data
    # in regard to the form fields, i.e. the form
    # field's label, its input type (e.g. radio, text,
    # textarea, select, etc.)
    # validators to check the user entered input against
    # a default value to use before the form is submitted
    # and an option group hash if the type of the form
    # input is select or radio
    # this hash should be keyed with the values you want
    # to use for the name attributes of your form inputs 
    my $fieldsData = shift;

    # values to populate value keys of field hashes with
    # generally this will be a hash of HTTP params
    # needs to have the same keys as fieldsData
    my $fieldValues = shift || {};

    my $self = {};

    bless($self, $class);

    # creates and populates fields hash
    $self->_setFields($fieldsData, $fieldValues);

    return $self;
}

# validates input and returns hash of fields 
# whose inputs are valid
sub validateFields {
    my $self   = shift;
    my $params = shift;

    # initialize hash of valid fields
    my %validFields = ();

    # init isValid property to 1
    # that is, the form starts out as
    # being valid until an invalid field
    # is found, at which point the form gets
    # set to invalid (i.e., $self->{isValid} = 0)
    $self->{isValid} = 1;

    # go through all the fields and look to see if they have any
    # validators, if so check the validators to see if the input
    # is valid, if the field has no validators then the field is
    # always valid
    foreach my $fieldName (keys %{$self->{fields}}) {

        my $field = $self->getField($fieldName);

        # if this field has any validators, run them
        if (scalar(@{$field->{validators}}) > 0) {

            # keeps track of how many validators pass
            my $validValidators = 0;

            # check the field's validator(s) to see if the user input is valid
            foreach my $validator (@{$field->{validators}}) {

                if ($validator->validate($params->{$fieldName})) {
                    # increment the validator counter because
		    # the current validator passed, i.e.
		    # the form input was good
                    $validValidators++;
                } else {
                    # mark field as invalid so error feedback can be
                    # displayed to the user
                    $field->{isValid} = 0;

                    # mark form as invalid because at least
		    # one input is not valid
                    $self->{isValid} = 0;

                    # add the validators feedback to the
		    # array of feedback for this field
                    push @{$field->{feedback}}, $validator->{feedback};
                }
	    }

            # only set the field to valid if ALL of the validators pass
            if (scalar(@{$field->{validators}}) == $validValidators) {
                $field->{isValid} = 1;
                $validFields{$fieldName} = $field->{value};
            }
        } else {
            # this field didn't have any validators so it's ok
            $field->{isValid} = 1;
            $validFields{$fieldName} = $field->{value};
        }
    }

    # return hash ref of valid fields
    return \%validFields;
}

sub validate_fields {
    my $self   = shift;
    my $params = shift;

    return $self->validateFields($params);
}

# returns all the fields in the form
sub getFields {
    my $self = shift;
    return $self->{fields};
}

# returns all the fields in the form
sub get_fields {
    my $self = shift;
    return $self->getFields();
}


# returns a field hash for the specified field name
sub getField {
    my $self      = shift;
    my $fieldName = shift;

    return $self->{fields}{$fieldName};
}

# returns a field hash for the specified field name
sub get_field {
    my $self      = shift;
    my $fieldName = shift;

    return $self->getField($fieldName);
}

# returns an array of the specified field name's
# feedback if there is any
sub getFieldErrorFeedback {
    my $self      = shift;
    my $fieldName = shift;

    my $field = $self->getField($fieldName);

    if ($field->{feedback}) {
        return @{$field->{feedback}};
    } else {
        return ();
    }
}

sub get_field_error_feedback {
    my $self      = shift;
    my $fieldName = shift;

    return $self->getFieldErrorFeedback($fieldName);
}

# returns the user entered value for a field
# or the default field value if useDefault
# is true
sub getFieldValue {
    my $self      = shift;
    my $fieldName = shift;

    return $self->getField($fieldName)->{value};
}

sub get_field_value {
    my $self      = shift;
    my $fieldName = shift;

    return $self->getFieldValue($fieldName);
}


# returns the label for the passes field hash
sub getFieldLabel {
    my $self  = shift;
    my $fieldName = shift;

    return $self->getField($fieldName)->{label};
}

sub get_field_label {
    my $self  = shift;
    my $fieldName = shift;

    return $self->getFieldLabel($fieldName);
}


# set value key of a field hash
sub setFieldValue {
    my $self      = shift;
    my $fieldName = shift;
    my $newValue  = shift;

    if (my $field = $self->getField($fieldName)) {
        $field->{value} = $newValue;
        #warn("set field value for field: $fieldName to '$new_value'");
    } else {
        #warn("could not find field for field name: '$fieldName'");
    }
}

sub set_field_value {
    my $self      = shift;
    my $fieldName = shift;
    my $newValue  = shift;

    $self->setFieldValue($fieldName, $newValue);
}

# returns true (i.e., 1) if all the required form fields are valid
sub isValid {
    my $self = shift;
    return $self->{isValid};
}

sub is_valid {
    my $self = shift;
    return $self->isValid();
}

# returns true if the HTTP request method
# matches the method_to_check
# $method_to_check is POST by default
# $request_method is the actual request method
# should be passed like $r->method()
# example usage:
#  returns true if HTTP request method is POST
#  $self->isSubmitted($r->method());
sub isSubmitted {
    my $self = shift;

    # the actual HTTP request method that the
    # form was sent using
    my $formRequestMethod = shift;

    # this should be GET or POST, defaults to POST
    my $formMethodToCheck = shift || 'POST';

    if ($formRequestMethod eq $formMethodToCheck) {
        return 1;
    } else {
        return 0;
    }
}

sub is_submitted {
    my $self = shift;

    my $formRequestMethod = shift;

    my $formMethodToCheck = shift || 'POST';

    return $self->isSubmitted($formRequestMethod,
                              $formMethodToCheck);
}

# sets fields hash
sub _setFields {
    my $self        = shift;
    my $fieldsData  = shift;
    my $fieldValues = shift;

    foreach my $fieldName (keys %{$fieldsData}) {
        # use the supplied field value if one is given
        # generally the supplied data will be a hash of
	# HTTP POST data
        my $fieldValue = '';

        # only use the default value of a check box if the form
        # has been submitted, that is, the default value
	# should be the value that you want to show up
	# in the POST data if the checkbox is selected when
	# the form is submitted
        if ($fieldsData->{$fieldName}{type} eq 'checkbox') {

            # if the checkbox was selected then we're going to use
	    # the default value for the checkbox input's value
	    # in our Form object, if the checkbox was not selected
	    # and the form was submitted that variable will not 
	    # show up in the hash of HTTP variables
            if ($fieldValues->{$fieldName}) {
                $fieldValue = $fieldsData->{$fieldName}{defaultValue};
            }

            # see if this checkbox should be checked by default
            $self->{fields}{$fieldName}{defaultChecked} = $fieldsData->{$fieldName}{defaultChecked};

	} else {
            if ($fieldValues->{$fieldName}) {
                $fieldValue = $fieldValues->{$fieldName};
            } else {
                $fieldValue = $fieldsData->{$fieldName}{defaultValue};
            }
        }

        # value suitable for displaying to users as
	# a label for a form input, e.g. 'Email address', 'Full name',
	# 'Street address', 'Phone number', etc.
        $self->{fields}{$fieldName}{label} = $fieldsData->{$fieldName}{label};

        # holds the value that the user enters after the
	# form is submitted
        $self->{fields}{$fieldName}{value} = $fieldValue;

        # the value to pre-populate a form input with before the form
	# is submitted, the only exception is a checkbox form input
	# in the case of a checkbox, the default value will be
	# the value of the checkbox input if the check box is selected
	# and the form is submitted, see form_test.pl for an example
        $self->{fields}{$fieldName}{defaultValue} = $fieldsData->{$fieldName}{defaultValue};

        # the validators for this field, validators are used to test
	# user entered form input to make sure that it the user entered
	# data is acceptable
        $self->{fields}{$fieldName}{validators} = \@{$fieldsData->{$fieldName}{validators}};

        # type of the form input, i.e. 'radio', 'text', 'select', 'checkbox', etc.
	# this is mainly used to determine what type of HTML method should be used
	# to display the form input in a web page
        $self->{fields}{$fieldName}{type} = $fieldsData->{$fieldName}{type};
        
        # if any validators fail, this property will contain the error feedback
	# associated with those failing validators
        $self->{fields}{$fieldName}{feedback} = ();

        # if the input type is a select box or a radio button then
	# we need an array of labels and values for the radio button group
	# or select box option groups
        if (my $optionsGroup = $fieldsData->{$fieldName}{optionsGroup}) {
            $self->{fields}{$fieldName}{optionsGroup} = \@{$optionsGroup};
        }
    }
}

#-------------------------------------------#
# Convenience methods for displaying HTML
# form data including form inputs, labels,
# and error feedback
# Note: You do not need to use these methods
# to display your form inputs, but they
# should be reasonably flexible enough to
# handle most cases
#-------------------------------------------#

# Returns HTML to display a form field input
sub getFieldFormInputHTML {
    my $self = shift;

    # the value of the HTML name attribute
    # of the form field
    my $fieldName = shift;

    # an string that can contain an
    # arbitrary number of HTML attribute
    # name=value pairs, this lets you
    # apply CSS classes to form inputs
    # or control the size of your text
    # inputs for example
    my $attributesString = shift || '';

    my $type = $self->getField($fieldName)->{type};

    if ($type =~ /text$|password|hidden/) {

        return $self->_getInputHTML($fieldName, $attributesString);

    } elsif ($type eq 'checkbox') {

        return $self->_getCheckBoxHTML($fieldName, $attributesString);

    } elsif ($type eq 'radio') {

        return $self->_getRadioButtonHTML($fieldName, $attributesString);

    } elsif ($type eq 'select') {

        return $self->_getSelectBoxHTML($fieldName, $attributesString);

    } elsif ($type eq 'textarea') {

        return $self->_getTextAreaHTML($fieldName, $attributesString);

    }
}

sub get_field_form_input_HTML {
    my $self = shift;

    # the value of the HTML name attribute
    # of the form field
    my $fieldName = shift;

    # an string that can contain an
    # arbitrary number of HTML attribute
    # name=value pairs, this lets you
    # apply CSS classes to form inputs
    # or control the size of your text
    # inputs for example
    my $attributesString = shift || '';

    return $self->getFieldFormInputHTML($fieldName,
                                        $attributesString);
}

# Returns a labeled form input including any feedback
# for the field
# returns HTML in the form of
# <tr>
# <td colspan="2">$errorFeedback</td>
# </tr>
# <tr>
# <td>$fieldLabel</td>
# <td>$formInput</td>
# </tr>
sub getFieldHTMLRow {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;

    my $field = $self->getField($fieldName);

    my @feedback = $self->getFieldErrorFeedback($fieldName);

    my $html = "";

    foreach my $error (@feedback) {
        $html .= "<tr><td colspan='2'>"
              . "<span style='color: #ff3300'>$error</span>"
	      . "</td></tr>\n";
    }

    $html .= "<tr><td>" . $field->{label} . "</td>"
          . "<td>" . $self->getFieldFormInputHTML($fieldName, $attributesString)
	  . "</td></tr>\n";

    return $html;
}

sub get_field_HTML_row {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;

    return $self->getFieldHTMLRow($fieldName,
                                  $attributesString);
}

# returns feedback for a field (if any) as HTML
sub getFieldFeedbackHTML {
    my $self      = shift;
    my $fieldName = shift;

    my @feedback = $self->getFieldErrorFeedback($fieldName);

    my $feedbackHTML = '';

    foreach my $fieldFeedback (@feedback) {
        $feedbackHTML .= "<div class='feedback'>\n";
        $feedbackHTML .= $fieldFeedback . "\n</div>\n";
    }

    return $feedbackHTML;
}

sub get_field_feedback_HTML {
    my $self      = shift;
    my $fieldName = shift;

    return $self->getFieldFeedbackHTML($fieldName);
}

#---------------------------------------#
# !!! private methods !!!
#---------------------------------------#

# Returns HTML to display a form text input.
sub _getInputHTML {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;    

    my $field = $self->getField($fieldName);

    my $inputHTML = "<input type='$field->{type}'"
	          . " name='$fieldName' value='";

    # use the user entered input as the value of the value attribute
    # or the default value if the user didn't entere anything for 
    # this form field
    if (my $userEnteredInput = $field->{value}) {
        $inputHTML .= $userEnteredInput;
    } else {
        $inputHTML .= $field->{defaultValue} || '';
    }

    $inputHTML .= "'" . $attributesString  . " />";

    return $inputHTML;
}

# Returns HTML to display a checkbox.
sub _getCheckBoxHTML {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;

    my $field = $self->getField($fieldName);

    if ($self->getFieldValue($fieldName) || $field->{defaultChecked}) {
        $attributesString .= " checked='checked'";
    }

   return $self->_getInputHTML($fieldName, $attributesString);
}

sub _getRadioButtonHTML {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;

    my $field = $self->getField($fieldName);

    # get the select boxes' list of options
    my $group = $field->{optionsGroup};

    my $inputHTML = '';

    if ($group) {
        foreach my $option (@{$group}) {
            # reset for each radio button in the group
            my $isChecked = '';

            my $value = $option->{value};
            my $label = $option->{label};

           if ($value eq $self->getFieldValue($fieldName)) {
                $isChecked = " checked='checked'";
           }

	    $inputHTML .= "<input type='$field->{type}'"
		          . " name='$fieldName' value='";

	    $inputHTML .= "$value'"
		       . $attributesString
		       . $isChecked
		       . " /> $label<br />";
        }
    } else {
        warn("No option group found for radio button group named: '$fieldName'");
    }
    return $inputHTML;
}

# Returns HTML to display a textarea.
sub _getTextAreaHTML {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;

    my $field = $self->getField($fieldName);

    my $textarea = "<textarea name='" . $fieldName . "'"
	         . $attributesString;

    $textarea .= ">";

    # use the user entered input as the value of the value attribute
    # or the default value if the user didn't entere anything for 
    # this form field
    if (my $userEnteredInput = $field->{value}) {
        $textarea .= $userEnteredInput;
    } else {
        $textarea .= $field->{defaultValue};
    }

    $textarea .= "</textarea>\n";

    return $textarea;
}

# Returns HTML to display a select box.
sub _getSelectBoxHTML {
    my $self             = shift;
    my $fieldName        = shift;
    my $attributesString = shift;

    my $html = "<select name='$fieldName'" . "$attributesString>\n";

    # get the select boxes' list of options
    my $group = $self->getField($fieldName)->{optionsGroup};

    if ($group) {
        foreach my $option (@{$group}) {
            my $value = $option->{value};
            my $label = $option->{label};

            # if the current user value is equal to the current option value
            # then the current option should be selected in the form
            my $isSelected;

	    if ($value eq $self->getField($fieldName)->{value}) {
                $isSelected = " selected='selected'";
            } else {
                $isSelected = "";
            }
            $html .= "<option value='$value'${isSelected}>$label</option>\n";
        }
    } else {
        warn("No option group found for select box named: '$fieldName'");
    }

    $html .= "</select>\n";
    return $html;
}

1;

__END__

=head1 NAME

WWW::Form

=cut

=head1 SYNOPSIS

The WWW::Form module provides a simple framework for 
programming and dealing with HTML forms.  It provides a simple
API which allows developers to deal with web form programming quickly,
flexibly, and consistently.

=cut

=head1 DESCRIPTION

This module:

=over 4

=item *
    provides functionality to handle all of the various types of HTML form inputs
    (this includes displaying HTML for the various form inputs)

=item *
    handles populating form inputs with user entered data or progammer specified
    default values

=item *
    provides robust validation of user entered input

=item *
    handles presenting customizable error feedback to users

=item *
    is easily extended, the Form module is designed to be easily inherited from, so
    you can easily add your own features.  You might want to write a Form subclass
    called MultiStepForm, which might provide "wizard" like functionality, for example.

=back

The most time consuming process (and it's not too bad) is creating the data
structure used for instantiating a Form object.  Once you have a Form object
almost all your work is done, as it will have enough information to handle
just about everything.

Before we get too involved in the details, let's take a look at a sample
usage of the WWW::Form module in a typical setting. Note: If you're using 
Apache::Request and mod_perl then your code would look a little different, 
but not in how the Form module is used, however.

    #!/usr/bin/perl
    use strict;
    use warnings;

    use CGI;
    use WWW::Form;
    # used by WWW::Form to perform various
    # validations on user entered input
    use WWW::FieldValidator;

    # gets us access to the HTTP request data
    my $q = CGI->new();

    # hash ref of HTTP vars
    # would be $r->param() if you're using mod_perl
    my $params = $q->Vars();

    my $form;
    if ($params) {
        $form = WWW::Form->new(getFormFields(), $params);
    } else {
        $form = WWW::Form->new(getFormFields());
    }    

    # check to see that the form was submitted by the user
    # if you're using mod_perl, instead of $ENV{REQUEST_METHOD}
    # you'd have $r->method()
    if ($form->isSubmitted($ENV{REQUEST_METHOD})) {

        # validate user entered data
        $form->validateFields($params);

        # if the data was good, do something
        if ($form->isValid()) {
            # do some stuff with params because we know the
	    # user entered data passed all of its
	    # validation
        }
    }

    # display the HTML web page
    print <<HTML;
    Content-Type: text/html

    <html>
    <head>
    <title>A Simple HTML Form</title>
    </head>
    <body>
    HTML
        print "<form action='./form_test.pl' method='post'>\n";
        print "<table border='0' cellspacing='2' cellpadding='5'>\n";

        # print field labels, form inputs, and error feedback (if any)
        # in a table. if you're willing to display all of your form
        # content in a table then this method is all you should ever need,
        # if not, it's still easy to use the Form module to present 
        # your form content however you want
        print $form->getFieldHTMLRow('emailAddress');
        print $form->getFieldHTMLRow('password');

        print "</table>\n\n";
        print <<HTML;
    <input type="submit" value="Submit" />
    </form>
    </body>
    </html>
    HTML

    # returns data structure suitable for passing
    # to Form object constructor, the keys will
    # become the names of the HTML form inputs
    sub getFormFields {
        my %fields = (
            emailAddress => {
                label        => 'Email address',
                defaultValue => 'you@emailaddress.com',
	        type         => 'text',
                validators   => [WWW::FieldValidator->new(
                                    WWW::FieldValidator::WELL_FORMED_EMAIL,
                                    'Make sure email address is well formed')]
            },
            password => {
                label        => 'Password',
	        defaultValue => '',
	        type         => 'password',
                validators   => [WWW::FieldValidator->new(
                                    WWW::FieldValidator::MIN_STR_LENGTH,
                                    'Password must be at least 6 characters', 6)]
	    }
        );
        return \%fields;
    }

=head2 Instantiating A Form Object

As I said, instantiating a form object is the trickiest part.  The Form constructor
takes two paramteters.  The first parameter called $fieldsData is a hash 
reference that describes how the form should be built.  $fieldsData should be keyed
with values that are suitable for using as the value of the form input's name 
HTML attribute.  That is, if you call a key of your $fieldsData hash 'full_name', then you
will have some type of form input whose name attribute will have the value 'full_name'.
The values of the $fieldsData keys (i.e., $fieldsData->{$fieldName}) should also 
be hash references.  This hash reference will be used to tell the Form module 
about your form input.  All of these hash references will be structured similarly, 
however, there are a couple of variations to accommodate the various types
of form inputs.  The basic structure is as follows:

 {
   label => 'Your name', # UI presentable value that will label the form input
   defaultValue => 'Homer Simpson', # if set, the form input will be pre-populated with this value
   type => 'text', # the type of form input, i.e. text, checkbox, textarea, etc. (more on this later)
   validators => [] # an array of various validations that should be performed on the user entered input
 }  

So to create a Form object with one text box you would have the following data structure:

 my $fields = {
   emailAddress => {
     label        => 'Email address',
     defaultValue => 'you@emailaddress.com',
     type         => 'text',
     validators   => [WWW::FieldValidator->new(
                        WWW::FieldValidator::WELL_FORMED_EMAIL,
                       'Make sure email address is well formed')]
            }
     };

You could then say the following to create that Form object:

  my $form = Form->new($fields);

Now let's talk about the second parameter.  If a form is submitted, then this second parameter
should be used.  It should be a hash reference of HTTP POST parameters. So if the previous
form was submitted you would instantiate the Form object like so:

  my $params = $r->param(); # or $q->Vars if you're using CGI
  my $form   = Form->new($fields, $params);

At this point, let me briefly discuss how to specify validators for your form inputs.

The validators keys in the $fieldsData hash reference can be left empty, which means
that the user entered input does not need to be validated at all, or it can take a
comma separated list of WWW::FieldValidator objects.  The basic format for a WWW::FieldValidator
constructor is as follows:

  WWW::FieldValidator->new($validatorType,
                           $errorFeedbackIfFieldNotValid,
                           # optional, depends on type of validator
                           $otherVarThatDependsOnType,
                           # optional boolean, if input is 
                           # entered validation is run, 
                           # if nothing is entered input is OK
                           $isOptional)

The FieldValidator types are:

  WWW::FieldValidator::WELL_FORMED_EMAIL
  WWW::FieldValidator::MIN_STR_LENGTH
  WWW::FieldValidator::MAX_STR_LENGTH
  WWW::FieldValidator::REGEX_MATCH
  WWW::FieldValidator::USER_DEFINED_SUB

So to create a validator for a field that would make sure the input
of said field was a minimum length, if any input was entered you would have:

  WWW::FieldValidator->new(WWW::FieldValidator::MIN_STR_LENGTH,
                           'Password must be at least 6 characters',
                           6, # input must be at least 6 chars
                           # input is only validated if user entered something
                           # if field left blank, it's OK
                           1)

=head2 How To Create All The Various Form Inputs

The following form input types are supported by the Form module
(these values should be used for the 'type' key of your $fieldsData->{$fieldName} hash ref):

text
password
hidden
checkbox
radio
select
textarea

The following structure can be used for text, password, hidden, and textarea form inputs:

 $fieldName => {
   label => 'Your name',
   defaultValue => 'Homer Simpson',
   type => 'text',
   validators => []
 } 

The following structure should be used for radio and select form inputs:

The data structure for input types radio and select use an array of hash references
called optionsGroup.  The optionsGroup label is what will be displayed in the select box or
beside the radio button, and the optionsGroup value is the value that will be in the hash of HTTP
params depending on what the user selects.  To pre-select a select box option or radio
button, set its defaultValue to a value that is found in the optionsGroup hash ref. For
example, if you wanted the option 'Blue' to be selected by default in the example below,
you would set defaultValue to 'blue'.

 $fieldName => {
   label        => 'Favorite color',
   defaultValue => '',
   type         => 'select',
   optionsGroup => [{label => 'Green', value => 'green'},
	            {label => 'Red',   value => 'red'},
		    {label => 'Blue',  value => 'blue'}],
   validators   => []
 } 

The following structure should be used for checkboxes:

Note: All checkbox form inputs need a defaultValue to be specified, this is the
value that will be used if the checkbox is checked when the form is submitted.  If
a checkbox is not checked then there will not be an entry for it in the hash of HTTP
POST params.  If defaultChecked is 1 the checkbox will be selected by default, if it is
0 it will not be selected by default.

 $fieldName => {
   label => 'Do you like spam>',
   defaultValue => 'Yes, I love it!',
   defaultChecked => 0, # 1 or 0
   type => 'checkbox',
   validators => []
 } 

=cut

=cut

=head2 Function Reference

The following section details the public API of the Form module.

NOTE: For style conscious developers all public methods are available
using internalCapsStyle and underscore_separated_style. So 'isSubmitted'
is also available as 'is_submitted', and 'getFieldHTMLRow' is also available
as 'get_field_HTML_row', and so on and so forth.

For most cases the following 5 methods should be all you need: new, isSubmitted, validateFields, isValid, and
getFieldHTMLRow.

B<new($fieldsData, $fieldsValues)>

Creates a Form object.  $fieldsData is a hash reference that describes your Form object. (See 
instantiating a Form object above.) $fieldsValues should be used when the form is submitted.  
The latter parameter has keys identical to $fieldsData. The $fieldsValues should be a hash
reference of HTTP POST variables.

  Example:

  my $params = $r->param();
  my $form;
  if ($params) {
    $form = Form->new($fieldsData, $params);
  } else {
    $form = Form->new($fieldsData);
  }



B<isSubmitted($HTTPRequestMethod)>

Returns true if the HTTP request method is POST.  If for some reason you're using GET to submit
a form then this method won't be of much help.

  Example:

  # returns true if HTTP method is POST
  $form->isSubmitted($r->method());



B<validateFields($params)>

Returns hash reference of all the fields that are valid (generally you don't need to use
this for anything though because if all the validation passes you can just use $params). 
Takes a hash reference of HTTP POST variables and validates their input 
according to the validators (WWW::FieldValidators) that were specified when 
the Form object was created.  This will also set error feedback as necessary for form inputs
that are not valid.

  Example:

  if ($form->isSubmitted($r->method)) {
    # validate fields because form was POSTed
    $form->validateFields($params);
  }



B<isValid()>

Returns true is all form fields are valid or false otherwise.

  Example:

  if ($form->isSubmitted($r->method)) {
    # validate fields because form was POSTed
    $form->validateFields($params);

    # now check to see if form inputs are all valid
    if ($form->isValid()) {
        # do some stuff with $params because we know
        # the validation passed for all the form inputs
    }
  }



B<getFieldHTMLRow($fieldName, [$attributesString])>

Returns HTML to display in a web page.  $fieldName is a key of the $fieldsData hash
that was used to create a Form object. $attributesString is an (optional) arbitrary
string of HTML attribute key='value' pairs that you can use to add attributes to the form
input.

The only caveat for using this method is that it must be called between <table> and </table>
tags.  It produces the following output:

  <!-- NOTE: The error feedback row(s) are only displayed if the field input was not valid -->
  <tr>
  <td colspan="2">$errorFeedback</td>
  </tr>
  <tr>
  <td>$fieldLabel</td>
  <td>$fieldFormInput</td>
  </tr>

  Example:

  $form->getFieldHTMLRow('name', " size='6' class='formField' ");


For more advanced form content handling the following methods
can be used.


B<getFieldFeedbackHTML($fieldName)>

Returns HTML error content for each vaildator belonging to $fieldName that doesn't pass validation.
Returns HTML as so:

  <div class='feedback'>
  $validatorOneErrorFeedback
  </div>
  <div class='feedback'>
  $validatorTwoErrorFeedback
  </div>
  <div class='feedback'>
  $validatorNErrorFeedback
  </div>

Note: If you use this, you should implement a CSS class named 'feedback' that styles
your error messages appropriately.


The following methods can be used to present form content any way you like.


B<getFieldFormInputHTML($fieldName, [$attributesString])>

Returns an HTML form input for the specified $fieldName. $attributesString is an (optional) arbitrary
string of HTML attribute key='value' pairs that you can use to add attributes to the form
input, such as size='20' or onclick='someJSFunction()', and so forth.


B<getFieldLabel($fieldName)>

Returns the label associated with the specified $fieldName.


B<getFieldErrorFeedback($fieldName)>

Returns an array of all the error feedback (if any) for the specified $fieldName.

The next couple of methods are somewhat miscellaneous.  They may be useful but in general
you shouldn't need them.


B<getFieldValue($fieldName)>

Returns the current value of the specified $fieldName.


B<setFieldValue($fieldName, $value)>

Sets the value of the specified $fieldName to $value.  You might use this if you need
to convert a user entered value to some other value.

=cut

=head1 SEE ALSO

WWW::FieldValidator

Note: If you want to use the validation features of WWW::Form you will need
to install WWW::FieldValidator also.

=cut

=head1 AUTHOR

Ben Schmaus

If you find this module useful or have any suggestions or comments please
send me an email at perlmods@benschmaus.com.

=cut

=head1 BUGS

Known that I know of, but please let me know if you find any.

Send email to perlmods@benschmaus.com.

=cut

=head1 COPYRIGHT

Copyright 2003, Ben Schmaus.  All Rights Reserved.

This program is free software.  You may copy or redistribute it under
the same terms as Perl itself.  If you find this module useful, please
let me know.

=cut
