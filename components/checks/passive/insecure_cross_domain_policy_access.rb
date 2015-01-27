=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

    This file is part of the Arachni Framework project and is subject to
    redistribution and commercial restrictions. Please see the Arachni Framework
    web site for more information on licensing and terms of use.
=end

# @author  Tasos Laskos <tasos.laskos@arachni-scanner.com>
# @version 0.1
class Arachni::Checks::InsecureCrossDomainPolicyAccess < Arachni::Check::Base

    def run
        url = "#{page.parsed_url.up_to_path}crossdomain.xml"
        return if audited?( url )
        audited( url )

        http.get( url, performer: self, &method(:check_and_log) )
    end

    def check_and_log( response )
        return if response.code != 200

        policy = Nokogiri::XML( response.body )
        return if !policy

        permissive_access = policy.search( 'allow-access-from[domain="*"]' )
        return if permissive_access.empty?

        log(
            proof:    permissive_access.to_xml,
            vector:   Element::Server.new( response.url ),
            response: response
        )
    end

    def self.info
        {
            name:        'Insecure cross-domain policy (allow-access-from)',
            description: %q{
Checks `crossdomain.xml` files for `allow-access-from` wildcard policies.
},
            author:      'Tasos Laskos <tasos.laskos@arachni-scanner.com>',
            version:     '0.1',
            elements:    [ Element::Server ],

            issue:       {
                name:        %q{Insecure cross-domain policy (allow-access-from)},
                description: %q{},
                references:  {},
                severity:    Severity::LOW,
                remedy_guidance: %q{}
            }
        }
    end

end
