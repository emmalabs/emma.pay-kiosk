#include "sys_stats_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <psapi.h>
#include <flutter_windows.h>
#include <Pdh.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace sys_stats
{
	static float CalculateCPULoad(unsigned long long idleTicks, unsigned long long totalTicks)
	{
		static unsigned long long _previousTotalTicks = 0;
		static unsigned long long _previousIdleTicks = 0;

		unsigned long long totalTicksSinceLastTime = totalTicks - _previousTotalTicks;
		unsigned long long idleTicksSinceLastTime = idleTicks - _previousIdleTicks;

		float ret = 1.0f - ((totalTicksSinceLastTime > 0) ? ((float)idleTicksSinceLastTime) / totalTicksSinceLastTime : 0);

		_previousTotalTicks = totalTicks;
		_previousIdleTicks = idleTicks;
		return ret;
	}

	static unsigned long long FileTimeToInt64(const FILETIME &ft) { return (((unsigned long long)(ft.dwHighDateTime)) << 32) | ((unsigned long long)ft.dwLowDateTime); }

	// Returns 1.0f for "CPU fully pinned", 0.0f for "CPU idle", or somewhere in between
	// You'll need to call this at regular intervals, since it measures the load between
	// the previous call and the current one.  Returns -1.0 on error.
	float getCPUUsage()
	{
		FILETIME idleTime, kernelTime, userTime;
		return GetSystemTimes(&idleTime, &kernelTime, &userTime) ? CalculateCPULoad(FileTimeToInt64(idleTime), FileTimeToInt64(kernelTime) + FileTimeToInt64(userTime)) : -1.0f;
	}

	static double getMemUsage()
	{
		MEMORYSTATUSEX memInfo;
		memInfo.dwLength = sizeof(MEMORYSTATUSEX);
		GlobalMemoryStatusEx(&memInfo);
		return memInfo.dwMemoryLoad;
	}

	static std::map<std::string, double> getStats()
	{
		std::map<std::string, double> stats;

		// Retrieve CPU usage information
		double cpuUsage = getCPUUsage();
		stats["cpu"] = cpuUsage;

		// Retrieve memory usage information
		double memUsage = getMemUsage();
		stats["memory"] = memUsage;

		return stats;
	}

	// static
	void SysStatsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows *registrar)
	{
		auto channel =
			std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
				registrar->messenger(), "sys_stats",
				&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<SysStatsPlugin>();

		channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto &call, auto result)
			{
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		registrar->AddPlugin(std::move(plugin));
	}

	SysStatsPlugin::SysStatsPlugin() {}

	SysStatsPlugin::~SysStatsPlugin() {}

	void SysStatsPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue> &method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		if (method_call.method_name().compare("getPlatformVersion") == 0)
		{
			std::ostringstream version_stream;
			version_stream << "Windows ";
			if (IsWindows10OrGreater())
			{
				version_stream << "10+";
			}
			else if (IsWindows8OrGreater())
			{
				version_stream << "8";
			}
			else if (IsWindows7OrGreater())
			{
				version_stream << "7";
			}
			result->Success(flutter::EncodableValue(version_stream.str()));
		}
		else if (method_call.method_name().compare("getStats") == 0)
		{
			// Retrieve CPU and memory usage information
			std::map<std::string, double> stats = getStats();

			// Create a Flutter map object to return the stats
			flutter::EncodableMap map;
			for (auto const &[key, value] : stats)
			{
				map[flutter::EncodableValue(key)] = flutter::EncodableValue(value);
			}

			result->Success(flutter::EncodableValue(map));
		}
		else
		{
			result->NotImplemented();
		}
	}

} // namespace sys_stats
