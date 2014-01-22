#!/usr/bin/env tclsh
# vim: sw=4
##############################################################################
# A Jekyll like text processing solution                                     #
#----------------------------------------------------------------------------#
# by: noyesno                                                                #
# at: Jan, 2014                                                              #
##############################################################################

proc walk_files {dir callback} {
    foreach f [glob -directory $dir -types "f" -nocomplain *.{[join "html txt" ","]} ] {
      puts stderr "File: $f" 
      $callback $f
    }
    foreach d [glob -directory $dir -tail -types "d" -nocomplain *] {
      if {[string index $d 0] eq "_"} continue
      walk_files [file join $dir $d ] $callback
    }
}

proc is_front_matter {file} {
  set fp [open $file r]
  set front [read $fp 3]
  close $fp
  if {$front eq "---"} {
    return true
  } else {
    return false
  }
}

proc process_file {file} {
  set fp [open $file r]
  gets $fp line
  set is_front_matter [expr {$line eq "---"}]
  while {$is_front_matter && [gets $fp line]>=0} {
    if {$line eq "---"} break
    set pos   [string first : $line]
    set key   [string range $line 0 $pos-1]
    set value [string trim [string range $line $pos+1 end]]
    set meta($key) $value
  }
  while {[gets $fp line]>=0} {
    if {$is_front_matter} {
      puts [subst -novariable $line]
    } else {
      puts $line
    }
  }
  close $fp
}


proc = {name} {
  set pos [string first $name .]
  if {$pos<0} {
    upvar meta lut 
  } else {
    upvar [string range $name 0 $pos-1] lut 
    set name [string range $name $pos+1 end]
  }
  return $lut($name) 
}
# interp alias {} = {} set 
walk_files . process_file 

