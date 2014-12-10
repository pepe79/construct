
module Construqt
  class Addresses

    UNREACHABLE = :unreachable
    LOOOPBACK = :looopback
    DHCPV4 = :dhcpv4
    DHCPV6 = :dhcpv6
    IPV4 = :ipv4
    IPV6 = :ipv6

    def initialize(network)
      @network = network
      @Addresses = []
    end

    def network
      @network
    end

    class Address
      attr_accessor :host
      attr_accessor :interface
      attr_accessor :ips
      attr_accessor :tags
      def dhcpv4?
        @dhcpv4
      end

      def dhcpv6?
        @dhcpv6
      end

      def loopback?
        @loopback
      end

      def initialize()
        self.ips = []
        self.host = nil
        self.interface = nil
        @routes = []
        self.tags = []
        @loopback = @dhcpv4 = @dhcpv6 = false
        @name = nil
      end

      def match_network(ip)
        if ip.ipv4?
          self.v4s.find{|nip| nip.include?(ip) }
        else
          self.v6s.find{|nip| nip.include?(ip) }
        end
      end

      def v6s
        self.ips.select{|ip| ip.ipv6? }
      end

      def v4s
        self.ips.select{|ip| ip.ipv4? }
      end

      def first_ipv4
        v4s.first
      end

      def first_ipv6
        v6s.first
      end

      def merge_tag(name, &block)
        Construqt::Tags.add(([name]+self.tags).join("#")) { |name| block.call(name) }
      end

      def tag(tag)
        self.tags << tag
        self
      end

      def set_name(xname)
        (@name, obj) = self.merge_tag(xname) { |xname| self }
        self
      end

      def name=(name)
        set_name(name)
      end

      def name
        ret = self.name!
        throw "unreferenced address [#{self.ips.map{|i| i.to_string }}]" unless ret
        ret
      end

      def name!
        return @name if @name
        return "#{self.interface.name}-#{self.interface.host.name}" if self.interface
        return self.host.name if self.host
        nil
      end

      def add_ip(ip, region = "")
        throw "please give a ip #{ip}" unless ip
        if ip
          #puts ">>>>> #{ip} #{ip.class.name}"
          if DHCPV4 == ip
            @dhcpv4 = true
          elsif DHCPV6 == ip
            @dhcpv6 = true
          elsif LOOOPBACK == ip
            @loopback = true
          else
            (unused, ip) = self.merge_tag(ip) { |ip| IPAddress.parse(ip) }
            self.ips << ip
          end
        end

        self
      end


      def routes
        @routes.map do |i|
            if i.kind_of?(Route)
              i
            else
              ret = []
              [OpenStruct.new(:dsts => Construqt::Tags.ips_net(i.dst_tag, Construqt::Addresses::IPV6),
                              :via => Construqt::Tags.ips_net(i.via_tag, Construqt::Addresses::IPV6)),
               OpenStruct.new(:dsts => Construqt::Tags.ips_net(i.dst_tag, Construqt::Addresses::IPV4),
                              :via => Construqt::Tags.ips_net(i.via_tag, Construqt::Addresses::IPV4))].each do |blocks|
                 next unless blocks.via
                 next unless blocks.via.first
                 next unless blocks.dsts
                 next if blocks.dsts.empty?
                 blocks.dsts.each do |dst|
                   ret << build_route(dst.to_string, blocks.via.first.to_s, i.options)
                 end
              end
              ret
            end
        end.flatten
      end
      #    @nameservers = []
      #    def add_nameserver(ip)
      #      @nameservers << IPAddress.parse(ip)
      #      self
      #    end
      #
      #
      class TagRoute
        attr_reader :dst_tag, :via_tag, :options
        def initialize(dst_tag, via_tag, options)
          @dst_tag = dst_tag
          @via_tag = via_tag
          @options = options
        end
      end

      def add_route_from_tags(dst_tags, src_tags, options = {})
        @routes << TagRoute.new(dst_tags, src_tags, options)
        self
      end

      def add_routes(addr_s, via, options = {})
        addrs = addr_s.kind_of?(Array) ? addr_s : [addr_s]
        addrs.each do |addr|
          if addr.respond_to? :ips
            ips = addr.ips if addr.respond_to? :ips
          else
            ips = [addr]
          end
          ips.each do |i|
            add_route(i.to_string, via, options)
          end
        end
        self
      end

      class Route
        attr_reader :dst, :via, :type, :metric
        def initialize(dst, via, type, metric)
          @dst = dst
          @via = via
          @type = type
          @metric = metric
        end
      end

      def build_route(dst, via, option = {})
        #puts "DST => "+dst.class.name+":"+dst.to_s
        (unused, dst) = self.merge_tag(dst) { |dst| IPAddress.parse(dst) }
        metric = option['metric']
        if via == UNREACHABLE
          via = nil
          type = 'unreachable'
        else
          if via.nil?
            via = nil
          else
            via = IPAddress.parse(via)
            throw "different type #{dst} #{via}" unless dst.ipv4? == via.ipv4? && dst.ipv6? == via.ipv6?
          end
          type = nil
        end
        Route.new(dst, via, type, metric)
      end


      def add_route(dst, via, option = {})
        @routes << build_route(dst, via, option)
        self
      end

      def to_s
        "<Address:Address #{@name}=>#{self.ips.map{|i| i.to_s}.join(":")}>"
      end
    end

    def create
      ret = Address.new()
      @Addresses << ret
      ret
    end

    def tag(tag)
      create.tag(tag)
    end

    def add_ip(ip, region = "")
      create.add_ip(ip, region)
    end

    def add_route(dest, via = nil)
      create.add_route(dest, via)
    end

    def set_name(name)
      create.set_name(name)
    end

    def all
      @Addresses
    end

    def v4_default_route(tag = "")
      nets = [(1..9),(11..126),(128..168),(170..171),(173..191),(193..223)].map do |range|
        range.to_a.map{|i| "#{i}.0.0.0/8"}
      end.flatten
      nets += (0..255).to_a.select{|i| i!=254}.map{|i| "169.#{i}.0.0/16" }
      nets += (0..255).to_a.select{|i| !(16<=i&&i<31)}.map{|i| "172.#{i}.0.0/16" }
      nets += (0..255).to_a.select{|i| i!=168}.map{|i| "192.#{i}.0.0/16" }

      v4_default_route = self.create
      v4_default_route.set_name(tag).tag(tag) if tag && !tag.empty?
      IPAddress::IPv4::summarize(*(nets.map{|i| IPAddress::IPv4.new(i) })).each do |i|
        v4_default_route.add_ip(i.to_string)
      end
      v4_default_route
    end
  end
end
