PREREQS(1)            User Contributed Perl Documentation           PREREQS(1)



Returns prereqs as string hash. If @filter contains phases, they are left out.

       Warns when filters don't exist only in verbose mode.

       prints prereqs package names only to STDOUT

       Prints prereqs from Meta file to STDOUT in a readable format

       TODO: Should I warn when phase is develop?

SSYYNNOOPPSSIISS
               prereqs.pl | cpanm
               prereqs.pl somefile.yml | cpanm
               prereqs.pl --list

DDEESSCCRRIIPPTTIIOONN
       Print the requires from yaml or json file.

OOPPTTIIOONNSS
       --list list phases, relationships and version numbers

       --verbose be more verbose

SSEEEE AALLSSOO
       CPAN::Meta, App::cpanminus

TTOODDOO
       * write tests

       * should I allow an option to print only those modules which are not
         installed? Doesn't seem essential.

PPOODD EERRRROORRSS
       Hey! TThhee aabboovvee ddooccuummeenntt hhaadd ssoommee ccooddiinngg eerrrroorrss,, wwhhiicchh aarree eexxppllaaiinneedd
       bbeellooww::

       Around line 54:
           Unknown directive: =func

       Around line 78:
           Unknown directive: =func

       Around line 99:
           Unknown directive: =func



perl v5.14.2                      2012-10-09                        PREREQS(1)
