
use strict;
use warnings;
use Test::More qw/no_plan/;
use RT;
use RT::Test;


{
    undef $main::_STDOUT_;
    undef $main::_STDERR_;

# {{{ Tests
ok (require RT::Group);

ok (my $group = RT::Group->new($RT::SystemUser), "instantiated a group object");
ok (my ($id, $msg) = $group->CreateUserDefinedGroup( Name => 'TestGroup', Description => 'A test group',
                    ), 'Created a new group');
ok ($id != 0, "Group id is $id");
ok ($group->Name eq 'TestGroup', "The group's name is 'TestGroup'");
my $ng = RT::Group->new($RT::SystemUser);

ok($ng->LoadUserDefinedGroup('TestGroup'), "Loaded testgroup");
ok(($ng->id == $group->id), "Loaded the right group");


ok (($id,$msg) = $ng->AddMember('1'), "Added a member to the group");
ok($id, $msg);
ok (($id,$msg) = $ng->AddMember('2' ), "Added a member to the group");
ok($id, $msg);
ok (($id,$msg) = $ng->AddMember('3' ), "Added a member to the group");
ok($id, $msg);

# Group 1 now has members 1, 2 ,3

my $group_2 = RT::Group->new($RT::SystemUser);
ok (my ($id_2, $msg_2) = $group_2->CreateUserDefinedGroup( Name => 'TestGroup2', Description => 'A second test group'), , 'Created a new group');
ok ($id_2 != 0, "Created group 2 ok- $msg_2 ");
ok (($id,$msg) = $group_2->AddMember($ng->PrincipalId), "Made TestGroup a member of testgroup2");
ok($id, $msg);
ok (($id,$msg) = $group_2->AddMember('1' ), "Added  member RT_System to the group TestGroup2");
ok($id, $msg);

# Group 2 how has 1, g1->{1, 2,3}

my $group_3 = RT::Group->new($RT::SystemUser);
ok (my ($id_3, $msg_3) = $group_3->CreateUserDefinedGroup( Name => 'TestGroup3', Description => 'A second test group'), 'Created a new group');
ok ($id_3 != 0, "Created group 3 ok - $msg_3");
ok (($id,$msg) =$group_3->AddMember($group_2->PrincipalId), "Made TestGroup a member of testgroup2");
ok($id, $msg);

# g3 now has g2->{1, g1->{1,2,3}}

my $principal_1 = RT::Principal->new($RT::SystemUser);
$principal_1->Load('1');

my $principal_2 = RT::Principal->new($RT::SystemUser);
$principal_2->Load('2');

ok (($id,$msg) = $group_3->AddMember('1' ), "Added  member RT_System to the group TestGroup2");
ok($id, $msg);

# g3 now has 1, g2->{1, g1->{1,2,3}}

is($group_3->HasMember($principal_2), undef, "group 3 doesn't have member 2");
ok($group_3->HasMemberRecursively($principal_2), "group 3 has member 2 recursively");
ok($ng->HasMember($principal_2) , "group ".$ng->Id." has member 2");
my ($delid , $delmsg) =$ng->DeleteMember($principal_2->Id);
ok ($delid !=0, "Sucessfully deleted it-".$delid."-".$delmsg);

#Gotta reload the group objects, since we've been messing with various internals.
# we shouldn't need to do this.
#$ng->LoadUserDefinedGroup('TestGroup');
#$group_2->LoadUserDefinedGroup('TestGroup2');
#$group_3->LoadUserDefinedGroup('TestGroup');

# G1 now has 1, 3
# Group 2 how has 1, g1->{1, 3}
# g3 now has  1, g2->{1, g1->{1, 3}}

ok(!$ng->HasMember($principal_2)  , "group ".$ng->Id." no longer has member 2");
is($group_3->HasMemberRecursively($principal_2), undef, "group 3 doesn't have member 2");
is($group_2->HasMemberRecursively($principal_2), undef, "group 2 doesn't have member 2");
is($ng->HasMember($principal_2), undef, "group 1 doesn't have member 2");;
is($group_3->HasMemberRecursively($principal_2), undef, "group 3 has member 2 recursively");

# }}}


    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

{
    undef $main::_STDOUT_;
    undef $main::_STDERR_;

ok(my $u = RT::Group->new($RT::SystemUser));
ok($u->Load(4), "Loaded the first user");
ok($u->PrincipalObj->ObjectId == 4, "user 4 is the fourth principal");
ok($u->PrincipalObj->PrincipalType eq 'Group' , "Principal 4 is a group");


    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

1;
