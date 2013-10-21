ad_library {

    futil package routines 
    @creation-date 18 Oct 2013

}

ad_proc -public tc_code_get {
    {filename_root ""}
} {
    Returns the code for an adp tcl filename pair, or the specific filename in the same directory 
    when the file pair does not exist. 
} {
    # Tyge Cawthon of http://highlandpiping.net inspired me to write this code for his documentation project -BB
    if { $filename_root eq "" } {
        set url [ad_conn url]
        set filename_root [file rootname [file tail $url]]
        set workdir "[acs_root_dir]/www[file dirname $url]"
    } else {
        set workdir "[acs_root_dir]/www[util_current_directory]"
    }
    set code ""
    set filename_list [list $filename_root "${filename_root}.adp" "${filename_root}.tcl" "${filename_root}.xql" "${filename_root}.txt"]
    set filename_title [list "File" "ADP Code" "TCL Code" "SQL Statements" "TXT File Contents"]
    set column 0

    foreach filename $filename_list {
        if [catch {open [file join $workdir $filename] r} fileId] {
            ns_log Notice "tc_code_get: file: '${workdir}${filename}' does not exist."
        } else {
            append code "<h3>[lindex $filename_title $column]:</h3><pre>\n"
            # Read and process the file
            while { [eof $fileId] != 1 } {
                gets $fileId line
                # ignore the line that grabs the code
                if { ![string match *tc_code_get* $line] } {
                    append code "[ad_quotehtml $line]\n"
                }
            }
            close $fileId
            append code "\n<pre>"
        }
        incr column
    }
    if { $code ne "" } {
        return $code
    } else {
        return "'${filename_root}.(adp/tcl/xql)' not found."
    }
}
