package Software::Catalog::SW::zoom::client;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny::With;
with 'Versioning::Scheme::Dotted';
with 'Software::Catalog::Role::Software';

use Config;
use Software::Catalog::Util qw(extract_from_url);

sub archive_info { [412, "Download URL is not regular archive"] }

sub available_versions { [501, "Not implemented"] }

sub platform_labels_to_specs {
    # XXX we should've parsed the download page

    # XXX for some linux distros, actually multiple versions are supported e.g.
    # for CentOS, Red Hat and Oracle Linux 8.0+ and 7.7.
    return {
        # label (specific to this software)  => platform spec
        linux32_ubu => "osflag=linux archname=~/i[3456]86/ oslabel=Ubuntu",
        linux64_ubu => "osflag=linux archname=x86_64 oslabel=Ubuntu",

        linux32_deb => "osflag=linux archname=~/i[3456]86/ oslabel=Debian",
        linux64_deb => "osflag=linux archname=x86_64 oslabel=Debian",

        #linux_min => "osflag=linux archname=x86_64 oslabel=Mint",

        #linux_ora => "osflag=linux archname=x86_64 oslabel=Oracle",

        linux32_cen => "osflag=linux archname=~/i[6]86/ oslabel=CentOS",
        linux64_cen => "osflag=linux archname=x86_64 oslabel=CentOS",

        #linux_red => "osflag=linux archname=x86_64 oslabel=RHEL",

        linux32_fed => "osflag=linux archname=~/i[6]86/ oslabel=Fedora",
        linux64_fed => "osflag=linux archname=x86_64 oslabel=Fedora",

        #linux_ope => "osflag=linux archname=x86_64 oslabel=OpenSUSE",

        #linux_arch => "osflag=linux archname=x86_64 oslabel=Arch",

        linux64_oth => "osflag=linux archname=x86_64 oslabel!~/(Ubuntu|Debian|Mint|Oracle|CentOS|RHEL|Fedora|OpenSUSE|Arch)/i",

        # XXX win64 etc not yet supported
    };
}

sub download_url {
    my ($self, %args) = @_;

    my $platform_label = $args{platform_label}
        or return [400, "Please specify platform_label"];

    if (defined $args{version}) {
        my $verres = $self->latest_version(platform_label => $args{platform_label});
        return [500, "Can't get latest version: $verres->[0] - $verres->[1]"]
            unless $verres->[0] == 200;
        return [412, "Can only return the latest version's download URL"]
            if $args{version} ne $verres->[2];
    }

    my $filename;
    if    ($platform_label =~ /^linux32_(ubu|deb|min)$/) { $filename = "zoom_i386.deb" }
    elsif ($platform_label =~ /^linux64_(ubu|deb|min)$/) { $filename = "zoom_amd64.deb" }
    elsif ($platform_label =~ /^linux64_(cen|red|fed)$/) { $filename = "zoom_i686.rpm" }
    elsif ($platform_label =~ /^linux64_(cen|red|fed)$/) { $filename = "zoom_x86_64.rpm" }
    elsif ($platform_label =~ /^linux32_(ope)$/)         { $filename = "zoom_openSUSE_i686.rpm" }
    elsif ($platform_label =~ /^linux64_(ope)$/)         { $filename = "zoom_openSUSE_x86_64.rpm" }
    elsif ($platform_label =~ /^linux64_(oth)$/)         { $filename = "zoom_x86_64.tar.xz" }
    else { return [412, "Unsupported platform label '$platform_label'"] }

    [200, "OK", "https://zoom.us/client/latest/$filename"];
}

sub homepage_url { "https://zoom.us" }

sub is_dedicated_profile { 0 }

sub latest_version {
    my ($self, %args) = @_;

    extract_from_url(
        # zoom website checks User-Agent string to offer download choices
        agent =>"LWP::UserAgent ($Config{archname})",
        url => "https://zoom.us/download",
        re  => qr{<span class="linux-ver-text"[^>]*>Version ([^<]+)</span>},
    );
}

sub release_note { [501, "Not implemented"] }

1;
# ABSTRACT: Zoom Cloud Meetings

=for Pod::Coverage ^(.+)$
