##
## Example custom Tcl-based simulation flow to run XSim simulation flows interactively [COMPILATION step]
##
## This script is a port in Tcl (with extensions) of the default compile.bat (compile.sh)
## script automatically generated by Vivado when running HDL simulations is project-mode.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##


####################################################################################################
##
## **NOTE
##
## Vivado extensively supports scripts-based flows either in so called "project" or "non-project"
## modes. Indeed, there is no "non-project mode" Tcl simulation flow. A "non-project" simulation flow
## is actually a true "batch flow" and requires to call standalone xvlog/xvhdl, xelab and xsim executables
## from the command-line, from a shell script or inside a GNU Makefile.
##
## However in "non-project mode" the simulation can't be re-invoked from the XSim GUI using
## Run > Relaunch Simulation (or using the relaunch_sim command) after RTL or testbench changes,
## thus requiring to exit from XSim and re-build the simulation from scratch. This happens because
## the XSim standalone flow doesn't keep track of xvlog/xvhdl and xelab flows.
##
## In order to be able to "relaunch" a simulation from the GUI you necessarily have to create a project
## in Vivado or to use a "project mode" Tcl script to automate the simulation.
## The overhead of creating an in-memory project is low compared to the benefits of fully automated
## one-step compilation/elaboration/simulation and re-launch features.
##
## This **CUSTOM** Tcl-based simulation flow basically reproduces all compilation/elaboration/simulation
## steps that actually Vivado performs "under the hood" for you without notice in project-mode.
## Most important, this custom flow is **PORTABLE** across Linux/Windows systems and allows
## to "relaunch" a simulation after RTL or testbench changes from the XSim Tcl console without
## the need of creating a project.
##
## Ref. also to  https://www.edn.com/improve-fpga-project-management-test-by-eschewing-the-ide
##
####################################################################################################


proc compile {} {

   ## profiling
   set tclStart [clock seconds]


   ############################################
   ##   parse HDL file names from Makefile   ##
   ############################################ 

   ## **LEGACY: only for reference (now moved into Makefile)
   #set RTL_DIR  [pwd]/../../rtl
   #set SIM_DIR  [pwd]/../../bench
   #set IPS_DIR  [pwd]/../../cores
   ## VHDL sources
   #set RTL_VHDL_SOURCES [glob -nocomplain ${RTL_DIR}/*.vhd]
   #
   ## Verilog/SystemVerilog sources
   #set RTL_VLOG_SOURCES [concat [glob -nocomplain ${RTL_DIR}/*.v] [glob -nocomplain ${RTL_DIR}/*.sv]]
   #
   ## IP sources (assume to already use Verilog gate-level netlists)
   #set IPS_SOURCES [glob -nocomplain ${IPS_DIR}/*/*netlist.v]
   #
   ## simulation sources (assume to write the testbench in Verilog or SystemVerilog)
   #set SIM_SOURCES [concat [glob -nocomplain ${SIM_DIR}/*.v] [glob -nocomplain ${SIM_DIR}/*.sv]]

   set vlogSources {}
   set vhdlSources {}
   set ipsSources  {}

   ## single HDL file to be compiled
   if { [info exists ::env(HDL_FILE)] } {

      set hdlFilePath  [file normalize ${::env(HDL_FILE)} ]
      set hdlFileExt   [file extension ${::env(HDL_FILE)} ]

      if { ${hdlFileExt} == ".vhd" || ${hdlFileExt} == ".vhdl"} {

         lappend vhdlSources ${hdlFilePath}

      } elseif { ${hdlFileExt} == ".v" || ${hdlFileExt} == ".sv" } {

         lappend vlogSources ${hdlFilePath} 

      } else {

         puts "\n**ERROR \[TCL\]: Unknown HDL file extension ${hdlFileExt} !\n\n"

         ## script failure
         exit 1
      }


   ## parse VLOG_SOURCES, VHDL_SOURCES and IPS_SOURCES environment variables otherwise
   } else {

      ## VLOG_SOURCES
      if { [info exists ::env(VLOG_SOURCES)] } {

         foreach src [split $::env(VLOG_SOURCES) " "] {

            lappend vlogSources [file normalize ${src} ]
         }
      }

      ## VHDL_SOURCES
      if { [info exists ::env(VHDL_SOURCES)] } {

         foreach src [split $::env(VHDL_SOURCES) " "] {

            lappend vhdlSources [file normalize ${src} ]
         }
      }

      ## IPS_SOURCES
      if { [info exists ::env(IPS_SOURCES)] } {

         foreach src [split $::env(IPS_SOURCES) " "] {

            lappend ipsSources [file normalize ${src} ]
         }
      }
   }


   #########################################
   ##   move to simulation working area   ##
   #########################################

   ## **IMPORTANT: assume to run the flow inside WORK_DIR/sim (the WORK_DIR environment variable is exported by Makefile)

   if { [info exists ::env(WORK_DIR)] } {

      cd ${::env(WORK_DIR)}/sim

   } else {

      puts "**WARN \[TCL\]: WORK_DIR environment variable not defined, assuming ./work/sim to run simulation flows."

      if { ![file exists work] } { file mkdir work/sim }
      cd work/sim
   }


   ###########################################
   ##   compile HDL sources (xvlog/xvhdl)   ##
   ###########################################

   ##
   ## **NOTE
   ##
   ## By using the 'catch' Tcl command the compilation process will continue until the end despite SYNTAX ERRORS
   ## are present inside input sources. All syntax errors are then shown on the console using 'grep' on the log file.
   ##


   ## log directory
   set logDir  [pwd]/../../log ; if { ![file exists ${logDir}] } { file mkdir ${logDir} }

   ## log file
   set logFile ${logDir}/compile.log

   ## delete the previous log file if exists
   if { [file exists ${logFile}] } {

      file delete ${logFile}
   }


   ## compile Verilog sources (xvlog)
   if { [llength ${vlogSources}] != 0 } {

      puts "\n"

      foreach src ${vlogSources} {

         if { [file exists ${src}] } {

            puts "Compiling Verilog source file ${src} ..."

            ## launch the xvlog executable from Tcl (force xvlog -sv to compile all sources as SystemVerilog files)
            catch {exec xvlog -relax -sv -work work ${src} -include [pwd]/../../rtl -define SIM -nolog | tee -a ${logFile} }

         } else {

            puts "**ERROR: ${src} not found!"

            ## script failure
            exit 1
         }
      }
   }


   ## compile VHDL sources (xvhdl)
   if { [llength ${vhdlSources}] != 0 } {

      puts "\n"

      foreach src ${vhdlSources} {

         if { [file exists ${src}] } {

            puts "Compiling VHDL source file ${src} ..."

            ## launch the xvhdl executable from Tcl
            catch {exec xvhdl -2008 -relax -work work ${src} -nolog | tee -a ${logFile} }

         } else {

            puts "**ERROR: ${src} not found!"

            ## script failure
            exit 1
         }
      }
   }


   ## compile IP sources (assume to use Verilog netlists, thus xvlog)
   if { [llength ${ipsSources}] != 0 } {
   
      puts "\n"

      foreach src ${ipsSources} {

         if { [file exists ${src}] } {

            puts "Compiling IP Verilog netlist ${src} ..."

            ## launch the xvlog executable from Tcl
            catch {exec xvlog -relax -sv -work work ${src} -nolog | tee -a ${logFile} }

         } else {

            puts "**ERROR: ${src} not found!"

            ## script failure
            exit 1
         }
      }
   }

   ## report CPU time
   set tclStop [clock seconds]
   set seconds [expr ${tclStop} - ${tclStart} ]

   puts "\nTotal elapsed-time for COMPILATION: [format "%.2f" [expr $seconds/60.]] minutes\n"


   #################################
   ##   check for syntax errors   ##
   #################################

   puts "\n-- Checking for syntax errors ...\n"

   if { [catch {exec grep --color ERROR ${logFile} >@stdout 2>@stdout }] } {

      puts "\t============================"
      puts "\t   NO SYNTAX ERRORS FOUND   "
      puts "\t============================"
      puts "\n"

      return 0

   } else {

      puts "\n"
      puts "\t=================================="
      puts "\t   COMPILATION ERRORS DETECTED !  "
      puts "\t=================================="
      puts "\n"

      puts "Please, fix all syntax errors and recompile sources.\n"

      return 1 
   }

}


## optionally, run the Tcl procedure when the script is executed by tclsh from Makefile
if { ${argc} == 1 } {

   if { [lindex ${argv} 0] eq "compile" } {

      puts "\n**INFO \[TCL\]: Running [file normalize [info script]]\n"

      if { [compile] } {

         ## compilation contains errors, exit with non-zero error code
         puts "Compilation **FAILED**"

         ## script failure
         exit 1

      } else {

         ## compilation OK
         exit 0
      }

   } else {

      ## invalid script argument, exit with non-zero error code
      puts "**ERROR \[TCL\]: Unknow option [lindex ${argv} 0]"

      ## script failure
      exit 1

   }
}
