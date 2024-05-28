use strict;
use warnings;
use lib '../lib', '../blib/arch', '../blib/lib';
use Affix;
$|++;
#
affix 'user32', GetSystemMetrics => [Int] => Int;
#
CORE::say 'width = ' . GetSystemMetrics(0);
CORE::say 'height = ' . GetSystemMetrics(1);
CORE::say 'number of monitors = ' . GetSystemMetrics(80);
