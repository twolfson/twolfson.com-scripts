# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Supervisor" do
  it "is installed" do
    supervisor_version_result = command("supervisorctl version")
    expect(supervisor_version_result.exit_status).to(eq(0))
    expect(supervisor_version_result.stdout.strip()).to(eq("3.2.0"))
  end

  it "has automatic start setup for supervisord" do
    expect(file("/etc/rc0.d/K20supervisord").link_target).to(eq("../init.d/supervisord"))
    expect(file("/etc/rc1.d/K20supervisord").link_target).to(eq("../init.d/supervisord"))
    expect(file("/etc/rc2.d/S20supervisord").link_target).to(eq("../init.d/supervisord"))
    expect(file("/etc/rc3.d/S20supervisord").link_target).to(eq("../init.d/supervisord"))
    expect(file("/etc/rc4.d/S20supervisord").link_target).to(eq("../init.d/supervisord"))
    expect(file("/etc/rc5.d/S20supervisord").link_target).to(eq("../init.d/supervisord"))
    expect(file("/etc/rc6.d/K20supervisord").link_target).to(eq("../init.d/supervisord"))
  end

  it "has expected permissions for log directory" do
    supervisor_log_dir = file("/var/log/supervisor")
    expect(supervisor_log_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(supervisor_log_dir.owner).to(eq(ROOT_USER))
    expect(supervisor_log_dir.group).to(eq(ROOT_GROUP))
  end

  it "has expected permissions for init.d script" do
    supervisor_init_d_file = file("/etc/init.d/supervisord")
    expect(supervisor_init_d_file.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(supervisor_init_d_file.owner).to(eq(ROOT_USER))
    expect(supervisor_init_d_file.group).to(eq(ROOT_GROUP))
  end

  it "has expected permissions for supervisor config" do
    supervisor_conf_file = file("/etc/supervisord.conf")
    expect(supervisor_conf_file.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(supervisor_conf_file.owner).to(eq(ROOT_USER))
    expect(supervisor_conf_file.group).to(eq(ROOT_GROUP))
  end

  it "has same pidfile in init.d script and supervisor.conf" do
    supervisor_init_d_file = file("/etc/init.d/supervisord")
    expect(supervisor_init_d_file.content).to(include("NAME=supervisord"))
    expect(supervisor_init_d_file.content).to(include("PIDFILE=/var/run/$NAME.pid"))
    supervisor_conf_file = file("/etc/supervisord.conf")
    expect(supervisor_conf_file.content).to(include("pidfile=/var/run/supervisord.pid"))
  end
end
