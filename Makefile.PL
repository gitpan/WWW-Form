use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	    => 'WWW::Form',
    'AUTHOR'        => 'Ben Schmaus <perlmods@benschmaus.com>',
    'VERSION_FROM'  => 'Form.pm', # finds $VERSION
    'PM'            => {'Form.pm' => '$(INST_LIBDIR)/Form.pm',
			'FieldValidator.pm' => '$(INST_LIBDIR)/FieldValidator.pm'},
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    'LIBS'		=> [''], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '', # e.g., '-I/usr/include/other'
);
