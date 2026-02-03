use strict;
use warnings;
use Cwd 'realpath';

my $BASE = '/srv/www';

sub shard {
    my ($id) = @_;
    return (int($id / 100), $id % 100);
}

my $app = sub {
    my $env = shift;

    my $host = $env->{HTTP_HOST} // '';
    $host =~ s/:\d+$//;
    $host =~ s/[^a-z0-9.\-]//gi;

    my $path = $env->{PATH_INFO} // '';

    return [404, [], []]
        unless $path =~ m{^/post/(\d+)/rd$};

    my $id = $1;
    my ($p, $l) = shard($id);

    my $rd_base = "$BASE/$host/_rd";
    my $rd_file = "$rd_base/$p/$l";

    my $real_base = realpath($rd_base)
        or return [404, [], []];

    my $real = realpath($rd_file)
        or return [404, [], []];

    return [403, [], []]
        unless index($real, $real_base) == 0;

    open my $fh, '<', $real
        or return [404, [], []];

    my $url = <$fh>;
    close $fh;

    $url //= '';
    $url =~ s/^\s+|\s+$//g;

    return [404, [], []]
        unless $url =~ m{^https?://}i;

    return [
        302,
        [ 'Location' => $url ],
        []
    ];
};

$app;
