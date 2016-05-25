-- license:BSD-3-Clause
-- copyright-holders:Robbbert

---------------------------------------------------------------------------
--
--   winui.lua
--
--   Rules for the building for Windows
--
---------------------------------------------------------------------------

dofile("modules.lua")

premake.make.linkoptions_after = false;

function maintargetosdoptions(_target,_subtarget)
	kind "WindowedApp"

	osdmodulestargetconf()

	configuration { "mingw*-gcc" }
		linkoptions {
			"-municode",
			"-lmingw32",
			"-Wl,--allow-multiple-definition",
		}

	configuration { "x64", "Release" }
		targetsuffix "ui64"

	configuration { "x64", "Debug" }
		targetsuffix "ui64d"

	configuration { "x32", "Release" }
		targetsuffix "ui"

	configuration { "x32", "Debug" }
		targetsuffix "uid"

	configuration { "Native", "Release" }
		targetsuffix "ui"

	configuration { "Native", "Debug" }
		targetsuffix "uid"

	configuration { }

	if _OPTIONS["DIRECTINPUT"] == "8" then
		links {
			"dinput8",
		}
	else
		links {
			"dinput",
		}
	end

	links {
		"comctl32",
		"comdlg32",
		"psapi",
		"ole32",
	}

	includedirs {
		MAME_DIR .. "src/osd/winui/res"
	}

-- Local file gives correct icon in mame instance inside of mameui
-- Local file must #include mameui.rc
	override_resources = true;
	rctarget = _target;
	local rcfile = MAME_DIR .. "src/osd/winui/" .. _target .. ".rc"
	local uifile = MAME_DIR .. "src/osd/winui/" .. _target .. "ui.rc"

	if not os.isfile(rcfile) then
		print(string.format("***** %s not found *****",rcfile))
		os.exit();
	end

	if not os.isfile(uifile) then
		print(string.format("***** %s not found *****",uifile))
		os.exit();
	end

	files {
		rcfile,
	}
	dependency {
		{ "$(OBJDIR)/".._target ..".res" ,  GEN_DIR  .. "/resource/" .. _target .. "vers.rc", true  },
	}
end


newoption {
	trigger = "DIRECTINPUT",
	description = "Minimum DirectInput version to support",
	allowed = {
		{ "7",  "Support DirectInput 7 or later"  },
		{ "8",  "Support DirectInput 8 or later" },
	},
}

if not _OPTIONS["DIRECTINPUT"] then
	_OPTIONS["DIRECTINPUT"] = "8"
end


project ("qtdbg_" .. _OPTIONS["osd"])
	uuid (os.uuid("qtdbg_" .. _OPTIONS["osd"]))
	kind (LIBTYPE)

	dofile("winui_cfg.lua")
	includedirs {
		MAME_DIR .. "src/emu",
		MAME_DIR .. "src/devices", -- accessing imagedev from debugger
		MAME_DIR .. "src/osd",
		MAME_DIR .. "src/lib",
		MAME_DIR .. "src/lib/util",
		MAME_DIR .. "src/osd/modules/render",
		MAME_DIR .. "3rdparty",
	}
	qtdebuggerbuild()

project ("osd_" .. _OPTIONS["osd"])
	uuid (os.uuid("osd_" .. _OPTIONS["osd"]))
	kind "StaticLib"

	dofile("winui_cfg.lua")
	osdmodulesbuild()

	defines {
		"DIRECT3D_VERSION=0x0900",
	}

	if _OPTIONS["DIRECTINPUT"] == "8" then
		defines {
			"DIRECTINPUT_VERSION=0x0800",
		}
	else
		defines {
			"DIRECTINPUT_VERSION=0x0700",
		}
	end

	includedirs {
		MAME_DIR .. "src/emu",
		MAME_DIR .. "src/devices",
		MAME_DIR .. "src/osd",
		MAME_DIR .. "src/lib",
		MAME_DIR .. "src/lib/util",
		MAME_DIR .. "src/osd/modules/file",
		MAME_DIR .. "src/osd/modules/render",
		MAME_DIR .. "3rdparty",
		MAME_DIR .. "src/frontend/mame",
		MAME_DIR .. "src/osd/windows",
	}

	files {
		MAME_DIR .. "src/osd/modules/render/d3d/d3d9intf.cpp",
		MAME_DIR .. "src/osd/modules/render/d3d/d3dintf.h",
		MAME_DIR .. "src/osd/modules/render/d3d/d3dhlsl.cpp",
		MAME_DIR .. "src/osd/modules/render/d3d/d3dcomm.h",
		MAME_DIR .. "src/osd/modules/render/d3d/d3dhlsl.h",
		MAME_DIR .. "src/osd/modules/render/drawd3d.cpp",
		MAME_DIR .. "src/osd/modules/render/drawd3d.h",
		MAME_DIR .. "src/osd/modules/render/drawgdi.cpp",
		MAME_DIR .. "src/osd/modules/render/drawgdi.h",
		MAME_DIR .. "src/osd/modules/render/drawnone.cpp",
		MAME_DIR .. "src/osd/modules/render/drawnone.h",
		MAME_DIR .. "src/osd/windows/video.cpp",
		MAME_DIR .. "src/osd/windows/video.h",
		MAME_DIR .. "src/osd/windows/window.cpp",
		MAME_DIR .. "src/osd/windows/window.h",
		MAME_DIR .. "src/osd/modules/osdwindow.cpp",
		MAME_DIR .. "src/osd/modules/osdwindow.h",
		MAME_DIR .. "src/osd/windows/winmain.cpp",
		MAME_DIR .. "src/osd/windows/winmain.h",
		MAME_DIR .. "src/osd/osdepend.h",
--		MAME_DIR .. "src/osd/windows/winmenu.cpp",
		MAME_DIR .. "src/osd/winui/newui.cpp",
		MAME_DIR .. "src/osd/windows/winmain.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/consolewininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/consolewininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/debugbaseinfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/debugbaseinfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/debugviewinfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/debugviewinfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/debugwininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/debugwininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/disasmbasewininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/disasmbasewininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/disasmviewinfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/disasmviewinfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/disasmwininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/disasmwininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/editwininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/editwininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/logwininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/logwininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/memoryviewinfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/memoryviewinfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/memorywininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/memorywininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/pointswininfo.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/pointswininfo.h",
		MAME_DIR .. "src/osd/modules/debugger/win/uimetrics.cpp",
		MAME_DIR .. "src/osd/modules/debugger/win/uimetrics.h",
		MAME_DIR .. "src/osd/modules/debugger/win/debugwin.h",
		MAME_DIR .. "src/osd/winui/bitmask.cpp",
		MAME_DIR .. "src/osd/winui/columnedit.cpp",
		MAME_DIR .. "src/osd/winui/datafile.cpp",
		MAME_DIR .. "src/osd/winui/datamap.cpp",
		MAME_DIR .. "src/osd/winui/dialogs.cpp",
		MAME_DIR .. "src/osd/winui/dijoystick.cpp",
		MAME_DIR .. "src/osd/winui/directdraw.cpp",
		MAME_DIR .. "src/osd/winui/directinput.cpp",
		MAME_DIR .. "src/osd/winui/directories.cpp",
		MAME_DIR .. "src/osd/winui/dirwatch.cpp",
		MAME_DIR .. "src/osd/winui/dxdecode.cpp",
		MAME_DIR .. "src/osd/winui/help.cpp",
		MAME_DIR .. "src/osd/winui/helpids.cpp",
		MAME_DIR .. "src/osd/winui/history.cpp",
		MAME_DIR .. "src/osd/winui/layout.cpp",
		MAME_DIR .. "src/osd/winui/mui_audit.cpp",
		MAME_DIR .. "src/osd/winui/mui_main.cpp",
		MAME_DIR .. "src/osd/winui/mui_opts.cpp",
		MAME_DIR .. "src/osd/winui/mui_util.cpp",
		MAME_DIR .. "src/osd/winui/picker.cpp",
		MAME_DIR .. "src/osd/winui/properties.cpp",
		MAME_DIR .. "src/osd/winui/resource.h",
		MAME_DIR .. "src/osd/winui/screenshot.cpp",
		MAME_DIR .. "src/osd/winui/splitters.cpp",
		MAME_DIR .. "src/osd/winui/tabview.cpp",
		MAME_DIR .. "src/osd/winui/treeview.cpp",
		MAME_DIR .. "src/osd/winui/winui.cpp",
		MAME_DIR .. "src/osd/winui/win_options.cpp",
	}

project ("ocore_" .. _OPTIONS["osd"])
	uuid (os.uuid("ocore_" .. _OPTIONS["osd"]))
	kind "StaticLib"

	options {
		"ForceCPP",
	}
	removeflags {
		"SingleOutputDir",	
	}

	dofile("windows_cfg.lua")
	
	includedirs {
		MAME_DIR .. "3rdparty",
		MAME_DIR .. "src/emu",
		MAME_DIR .. "src/osd",
		MAME_DIR .. "src/osd/modules/file",
		MAME_DIR .. "src/lib",
		MAME_DIR .. "src/lib/util",
	}

	BASE_TARGETOS = "win32"
	SDLOS_TARGETOS = "win32"
	SYNC_IMPLEMENTATION = "windows"

	includedirs {
		MAME_DIR .. "src/osd/windows",
		MAME_DIR .. "src/lib/winpcap",
	}

	files {
		MAME_DIR .. "src/osd/eigccppc.h",
		MAME_DIR .. "src/osd/eigccx86.h",
		MAME_DIR .. "src/osd/eivc.h",
		MAME_DIR .. "src/osd/eivcx86.h",
		MAME_DIR .. "src/osd/eminline.h",
		MAME_DIR .. "src/osd/osdcomm.h",
		MAME_DIR .. "src/osd/osdcore.cpp",
		MAME_DIR .. "src/osd/osdcore.h",
		MAME_DIR .. "src/osd/strconv.cpp",
		MAME_DIR .. "src/osd/strconv.h",
		MAME_DIR .. "src/osd/windows/main.cpp",
		MAME_DIR .. "src/osd/windows/windir.cpp",
		MAME_DIR .. "src/osd/osdsync.cpp",
		MAME_DIR .. "src/osd/osdsync.h",
		MAME_DIR .. "src/osd/windows/winutf8.cpp",
		MAME_DIR .. "src/osd/windows/winutf8.h",
		MAME_DIR .. "src/osd/windows/winutil.cpp",
		MAME_DIR .. "src/osd/windows/winutil.h",
		MAME_DIR .. "src/osd/modules/osdmodule.cpp",
		MAME_DIR .. "src/osd/modules/osdmodule.h",
		MAME_DIR .. "src/osd/modules/file/winfile.cpp",
		MAME_DIR .. "src/osd/modules/file/winfile.h",
		MAME_DIR .. "src/osd/modules/file/winptty.cpp",
		MAME_DIR .. "src/osd/modules/file/winsocket.cpp",
		MAME_DIR .. "src/osd/modules/lib/osdlib_win32.cpp",
	}


--------------------------------------------------
-- ledutil
--------------------------------------------------

if _OPTIONS["with-tools"] then
	project("ledutil")
		uuid ("061293ca-7290-44ac-b2b5-5913ae8dc9c0")
		kind "ConsoleApp"

		if _OPTIONS["SEPARATE_BIN"]~="1" then 
			targetdir(MAME_DIR)
		end

		links {
			"ocore_" .. _OPTIONS["osd"],
		}

		includedirs {
			MAME_DIR .. "src/osd",
		}

		files {
			MAME_DIR .. "src/osd/windows/ledutil.cpp",
		}
end

