#include "include/sys_stats/sys_stats_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <cstdio>
#include <map>
#include <fstream>
#include <sstream>
#include <chrono>
#include <thread>
#include <unistd.h>
#include <sys/sysinfo.h>

#define SYS_STATS_PLUGIN(obj)                                       \
	(G_TYPE_CHECK_INSTANCE_CAST((obj), sys_stats_plugin_get_type(), \
								SysStatsPlugin))

// Get OS Name and Version
std::string getOsInfo()
{
	std::string os, line;
	std::ifstream file("/etc/os-release");
	if (file.is_open())
	{
		while (getline(file, line))
		{
			if (line.find("PRETTY_NAME") != std::string::npos)
			{
				os = line.substr(line.find("=") + 1);
				break;
			}
		}
		file.close();
	}
	return os;
}

// Get CPU Model
std::string getCpuInfo()
{
	std::string cpu, line;
	std::ifstream file("/proc/cpuinfo");
	if (file.is_open())
	{
		while (getline(file, line))
		{
			if (line.find("model name") != std::string::npos)
			{
				cpu = line.substr(line.find(":") + 2);
				break;
			}
		}
		file.close();
	}
	return cpu;
}

// Get Total Memory
long int getTotalMemory()
{
	long int mem = 0;
	std::string line;
	std::ifstream file("/proc/meminfo");
	if (file.is_open())
	{
		getline(file, line);
		mem = std::stoi(line.substr(line.find(":") + 2, line.find("kB") - line.find(":") - 3));
		file.close();
	}
	return mem;
}

// Get Memory Usage
long int getMemoryUsage()
{
	long int mem = 0;
	std::string line;
	std::ifstream file("/proc/meminfo");
	if (file.is_open())
	{
		getline(file, line);
		mem = getTotalMemory() - std::stoi(line.substr(line.find(":") + 2, line.find("kB") - line.find(":") - 3));
		file.close();
	}
	return mem;
}

// Get Total Disk Space
long int getTotalDiskSpace(std::string device)
{
	long int total = 0;
	std::string command = "df -B1 | grep " + device + " | awk '{print $2}'";
	FILE *pipe = popen(command.c_str(), "r");
	if (!pipe)
	{
		return 0;
	}
	char buffer[128];
	fgets(buffer, 128, pipe);
	total = std::stoi(std::string(buffer));
	pclose(pipe);
	return total;
}

// Get Disk Usage
long int getDiskUsage(std::string device)
{
	long int used = 0;
	std::string command = "df -B1 | grep " + device + " | awk '{print $3}'";
	FILE *pipe = popen(command.c_str(), "r");
	if (!pipe)
	{
		return 0;
	}
	char buffer[128];
	fgets(buffer, 128, pipe);
	used = std::stoi(std::string(buffer));
	pclose(pipe);
	return used;
}

static double getCPUUsage()
{
	static uint64_t lastTotalUser, lastTotalUserLow, lastTotalSys, lastTotalIdle;
	double percent;

	std::ifstream fileStat("/proc/stat");
	std::string line;
	std::getline(fileStat, line);
	std::istringstream ss(line);
	ss.ignore(5);
	uint64_t totalUser, totalUserLow, totalSys, totalIdle;
	ss >> totalUser >> totalUserLow >> totalSys >> totalIdle;
	uint64_t total = totalUser + totalUserLow + totalSys + totalIdle;
	if (lastTotalIdle != 0)
	{
		uint64_t nonIdle = total - totalIdle - (lastTotalUser - lastTotalUserLow) - (lastTotalSys - lastTotalUser);
		percent = (nonIdle * 100.0) / total;
	}
	else
	{
		percent = 0.0;
	}
	lastTotalUser = totalUser;
	lastTotalUserLow = totalUserLow;
	lastTotalSys = totalSys;
	lastTotalIdle = totalIdle;
	std::this_thread::sleep_for(std::chrono::milliseconds(100)); // Wait for a short time
	return percent;
}

static std::map<std::string, double> getStats()
{
	std::map<std::string, double> stats;

	// Retrieve CPU usage information
	double cpuUsage = getCPUUsage();
	stats["cpu"] = cpuUsage;

	// Retrieve memory usage information
	double memUsage = getMemoryUsage();
	stats["memory"] = memUsage;

	return stats;
}

struct _SysStatsPlugin
{
	GObject parent_instance;
};

G_DEFINE_TYPE(SysStatsPlugin, sys_stats_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void sys_stats_plugin_handle_method_call(
	SysStatsPlugin *self,
	FlMethodCall *method_call)
{
	g_autoptr(FlMethodResponse) response = nullptr;

	const gchar *method = fl_method_call_get_name(method_call);

	if (strcmp(method, "getPlatformVersion") == 0)
	{
		struct utsname uname_data = {};
		uname(&uname_data);
		g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
		g_autoptr(FlValue) result = fl_value_new_string(version);
		response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
	}
	else if (strcmp(method, "getStats") == 0)
	{
		// Retrieve CPU and memory usage information
		std::map<std::string, double> stats = getStats();

		// Create a Flutter map object to return the stats
		g_autoptr(FlValue) map = fl_value_new_map();
		for (const auto &pair : stats)
		{
			const std::string &key = pair.first;
			double value = pair.second;

			fl_value_set(map, fl_value_new_string(key.c_str()), fl_value_new_float(value));
		}
		response = FL_METHOD_RESPONSE(fl_method_success_response_new(map));
	}
	else
	{
		response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
	}

	fl_method_call_respond(method_call, response, nullptr);
}

static void sys_stats_plugin_dispose(GObject *object)
{
	G_OBJECT_CLASS(sys_stats_plugin_parent_class)->dispose(object);
}

static void sys_stats_plugin_class_init(SysStatsPluginClass *klass)
{
	G_OBJECT_CLASS(klass)->dispose = sys_stats_plugin_dispose;
}

static void sys_stats_plugin_init(SysStatsPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
						   gpointer user_data)
{
	SysStatsPlugin *plugin = SYS_STATS_PLUGIN(user_data);
	sys_stats_plugin_handle_method_call(plugin, method_call);
}

void sys_stats_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
	SysStatsPlugin *plugin = SYS_STATS_PLUGIN(
		g_object_new(sys_stats_plugin_get_type(), nullptr));

	g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
	g_autoptr(FlMethodChannel) channel =
		fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
							  "sys_stats",
							  FL_METHOD_CODEC(codec));
	fl_method_channel_set_method_call_handler(channel, method_call_cb,
											  g_object_ref(plugin),
											  g_object_unref);

	g_object_unref(plugin);
}