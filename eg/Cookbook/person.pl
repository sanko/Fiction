use Affix;
typedef person_t => Pointer [Void];
affix './person.so', person_new  => [ Str, UInt ]  => person_t();
affix './person.so', person_name => [ person_t() ] => Str;
affix './person.so', person_age  => [ person_t() ] => UInt;
affix './person.so', person_free => [ person_t() ] => Void;
my $person = person_new( 'Roger Frooble Bits', 35 );
print "name = ", person_name($person), "\n";
print "age  = ", person_age($person),  "\n";
person_free($person);
