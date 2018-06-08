#
module ZoneUtils
  def clean(agent)
    on(agent, 'zoneadm list -cip').stdout.lines.each do |l|
      case l
      when %r{tstzone:running}
        on agent, 'zoneadm -z tstzone halt'
        on agent, 'zoneadm -z tstzone uninstall -F'
        on agent, 'zonecfg -z tstzone delete -F'
        on agent, 'rm -f /etc/zones/tstzone.xml'
      when %r{tstzone:configured}
        on agent, 'zonecfg -z tstzone delete -F'
        on agent, 'rm -f /etc/zones/tstzone.xml'
      when %r{tstzone:*}
        on agent, 'zonecfg -z tstzone delete -F'
        on agent, 'rm -f /etc/zones/tstzone.xml'
      end
    end
    on(agent, 'zfs list').stdout.lines.each do |l|
      case l
      when %r{rpool.tstzones}
        on agent, 'zfs destroy -f -r rpool/tstzones'
      end
    end
    on agent, 'rm -rf /tstzones'
  end
  module_function :clean
end
