# source into your shell
export PERL6LIB=".:jdbclib:$PERL6LIB"

# Also need to ensure the native postgres libpq is loadable
# For OS X you'll need something like this in your ~/.profile
# export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/pgsql/lib/

