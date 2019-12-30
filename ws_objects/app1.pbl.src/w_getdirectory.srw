$PBExportHeader$w_getdirectory.srw
$PBExportComments$[kEnn] Get Directory Name
forward
global type w_getdirectory from window
end type
type p_dropdown from picture within w_getdirectory
end type
type dw_1 from datawindow within w_getdirectory
end type
type sle_dir from singlelineedit within w_getdirectory
end type
type ddlb_1 from dropdownlistbox within w_getdirectory
end type
type cb_cancel from commandbutton within w_getdirectory
end type
type cb_1 from commandbutton within w_getdirectory
end type
type st_1 from statictext within w_getdirectory
end type
type st_dir from statictext within w_getdirectory
end type
type p_back_up from picture within w_getdirectory
end type
type p_back_down from picture within w_getdirectory
end type
type p_back_off from picture within w_getdirectory
end type
type lv_files from listview within w_getdirectory
end type
type plb_drives from picturelistbox within w_getdirectory
end type
type tv_1 from treeview within w_getdirectory
end type
end forward

global type w_getdirectory from window
integer x = 1056
integer y = 484
integer width = 1952
integer height = 1036
boolean titlebar = true
string title = "Select Directory"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 79741120
p_dropdown p_dropdown
dw_1 dw_1
sle_dir sle_dir
ddlb_1 ddlb_1
cb_cancel cb_cancel
cb_1 cb_1
st_1 st_1
st_dir st_dir
p_back_up p_back_up
p_back_down p_back_down
p_back_off p_back_off
lv_files lv_files
plb_drives plb_drives
tv_1 tv_1
end type
global w_getdirectory w_getdirectory

type variables
Private:
string is_original_directory, is_selected_directory
string isa_drives[]
string is_return

end variables

forward prototypes
public function integer wf_populate_treeview (string arg_directory)
public function long wf_gethandle (string foldername)
public function string wf_getdirfromhandle (long arg_handle)
public function integer wf_populate (string arg_directory)
public function integer wf_initialize_treeview ()
public function string wf_extractparentdir (string arg_directory)
public function integer wf_populate_listview (string arg_directory)
end prototypes

public function integer wf_populate_treeview (string arg_directory);integer li_len,c,li_pos
string ls_arg,ls_folder
long ll_parent,ll_child,ll_row,ll_handle

// populates the treeview with the new directories that are shown in the plb
// arg is the folder that should be showing in the treeview
// Note:  we are only populating the selected folders in the tree vs. all folders below a given level

setpointer(hourglass!)
// ie.  arg = C:\Temp\Test
// take off the last subdirectory and find the handle using the datawindow
//messagebox('pop tree',arg_directory)
ll_handle = wf_gethandle(arg_directory)
if ll_handle > 0 then  // first see if it is already in the tree
	tv_1.selectitem(ll_handle)
	return 0
end if
li_len = LenA(arg_directory)
if li_len > 2 then  // if it is not just a drive letter
	for c = li_len to 3 step -1
		li_pos = PosA(arg_directory,'\',c)
		if li_pos > 0 then
			ls_arg = MidA(arg_directory,1,li_pos - 1)
			ls_folder = MidA(arg_directory,li_pos + 1)
			exit
		end if
	next
else
	ls_arg = ' (' + arg_directory + ')'
end if
if LenA(ls_arg) = 2 then
	ls_arg = ' (' + ls_arg + ')'
end if	
// so, look for C:\Temp in the dw to get that handle
ll_parent = wf_gethandle(ls_arg)
if ll_parent > 0 then
	// add Test onto the parent's handle that was just retrieved if it doesn't exist yet
	ll_child = tv_1.insertitemlast(ll_parent,ls_folder,3)
	tv_1.selectitem(ll_child)
	ll_row = dw_1.insertrow(0)
	dw_1.setitem(ll_row,1,arg_directory)
	dw_1.setitem(ll_row,2,ll_child)
	dw_1.setitem(ll_row,3,ll_parent)
end if

return 0

end function

public function long wf_gethandle (string foldername);//wf_gethandle(ls_fullpath)

string ls_expr
long ll_handle,ll_rowid

//ls_expr = "label = ~'" + foldername + "~' and parenthandle = " + string(parenthandle)
ls_expr = "label = ~'" + foldername + "~'"
ll_rowid = dw_1.find(ls_expr,1,dw_1.rowcount())
if ll_rowid > 0 and ll_rowid <= dw_1.rowcount() then
	ll_handle = dw_1.getitemnumber(ll_rowid,2)
end if

return ll_handle

end function

public function string wf_getdirfromhandle (long arg_handle);// we can find the full path name in the datawindow if we know the item handle
string ls_fulldir,ls_expr
long ll_handle,ll_rowid

ls_expr = "itemhandle = " + string(arg_handle)
ll_rowid = dw_1.find(ls_expr,1,dw_1.rowcount())
if ll_rowid > 0 and ll_rowid <= dw_1.rowcount() then
	ls_fulldir = dw_1.getitemstring(ll_rowid,1)
end if
if LeftA(ls_fulldir,2) = ' (' then
	ls_fulldir = MidA(ls_fulldir,3,2)
end if

ls_fulldir = upper(LeftA(ls_fulldir,1)) + MidA(ls_fulldir,2)

return ls_fulldir


end function

public function integer wf_populate (string arg_directory);integer li_len,li_pos,c,li,li_return
string ls_currdir,ls_folder
string ls_subdir

// takes in a directory and populates the drop down and list view with data about THAT directory
// use wf_extractparentdir to get the parent directory

arg_directory = upper(LeftA(arg_directory,1)) + MidA(arg_directory,2)

setpointer(hourglass!)
// Populates the drive letter or the current subdirectory
if LenA(arg_directory) = 2 then
	ls_currdir = ' (' + upper(LeftA(arg_directory,1)) + ':)'
	li_return = wf_populate_listview(arg_directory)
	if li_return >= 0 then
		plb_drives.reset()
		plb_drives.additem(ls_currdir,2)
	end if
	sle_dir.text = arg_directory + '\'
	is_selected_directory = arg_directory
	return li_return
end if

choose case arg_directory
	case 'Desktop'  // populate all the drive letters and display desktop in the picklist
		plb_drives.reset()
		lv_files.deleteitems()
		plb_drives.additem('Desktop',1)
		wf_populate_listview('Desktop')
		sle_dir.text = ''
	case 'Error'
		plb_drives.reset()
		lv_files.deleteitems()
		sle_dir.text = ''
	case ''
		messagebox('Error','Empty parm value passed to wf_populate.')
		sle_dir.text = ''
		return -1
	case else
		li_len = LenA(arg_directory)
		for c = li_len to 1 step -1
			li_pos = PosA(arg_directory,'\',c)
			if li_pos > 0 then
				ls_folder = MidA(arg_directory,li_pos + 1)
				If AscA(LeftA(ls_folder,1)) >= 97 and AscA(LeftA(ls_folder,1)) <= 122 Then
					ls_folder = upper(LeftA(ls_folder,1)) + MidA(ls_folder,2)
				End If
				plb_drives.reset()
				plb_drives.additem(ls_folder,4)
				wf_populate_listview(arg_directory)
				sle_dir.text = arg_directory
				wf_populate_treeview(arg_directory)
				is_selected_directory = arg_directory
				exit
			end if
		next
end choose
return 0
end function

public function integer wf_initialize_treeview ();/* Mataya - Jan 14, 99
This wf will populate the treeview with the Desktop, Drives, and the 
current directory folder structure.  We'll store all handles, labels, and
parent handles into the datawindow.
*/

long ll_parent,ll_child,ll_dw_row
integer i,li_items,li_start,li_pos
treeviewitem ltvi
string ls,ls_drive,ls_dir,ls_folder,ls_buildpath

// insert the first item
ll_parent = tv_1.InsertItemLast(0,'Desktop',1)
ll_dw_row = dw_1.insertrow(0)
dw_1.setitem(ll_dw_row,1,'Desktop')
dw_1.setitem(ll_dw_row,2,1)
dw_1.setitem(ll_dw_row,3,0)

// get all of the drives
ddlb_1.dirlist('*.*',16384)
li_items = ddlb_1.totalitems()
if li_items < 1 then
	messagebox('Error','Could not find any drives.')
	return -1
end if
for i = 1 to li_items
	ls = ' (' + upper(MidA(ddlb_1.text(i),3,1)) + ':)'
	ll_child = tv_1.insertitemlast(ll_parent,ls,2)
	ll_dw_row = dw_1.insertrow(0)
	dw_1.setitem(ll_dw_row,1,ls)
	dw_1.setitem(ll_dw_row,2,ll_child)
	dw_1.setitem(ll_dw_row,3,ll_parent)
next

// now get the subdirectories built in the tree view and expand to that item
// ie C:\Program\Test\Temp
ls_dir = is_selected_directory
// first get the drive letter, then get the tv handle
ls_drive = ' (' + upper(LeftA(ls_dir,1)) + ':)'
ll_parent = wf_gethandle(ls_drive)

// start on 4 and find the next \
li_start = 4
li_pos = PosA(ls_dir,'\',li_start)
if li_pos = 0 and li_start < LenA(ls_dir) then li_pos = LenA(ls_dir) + 1
do until li_pos = 0
	ls_folder = MidA(ls_dir,li_start,li_pos - li_start)

	If AscA(LeftA(ls_folder,1)) >= 97 and AscA(LeftA(ls_folder,1)) <= 122 Then
		ls_folder = upper(LeftA(ls_folder,1)) + MidA(ls_folder,2)
	End If

	ls_buildpath = MidA(ls_dir,1,li_pos - 1)
	ls_buildpath = upper(LeftA(ls_buildpath,1)) + MidA(ls_buildpath,2)
	// add this folder item to the tree and dw
	ll_child = tv_1.insertitemlast(ll_parent,ls_folder,3)
	//dw_1.setitem(ll_dw_row,1,ls_folder)
	ll_dw_row = dw_1.insertrow(0)
	dw_1.setitem(ll_dw_row,1,ls_buildpath)
	dw_1.setitem(ll_dw_row,2,ll_child)
	dw_1.setitem(ll_dw_row,3,ll_parent)
	ll_parent = ll_child
	li_start = li_pos + 1
	li_pos = PosA(ls_dir,'\',li_start)
	if li_pos = 0 and li_start < LenA(ls_dir) then li_pos = LenA(ls_dir) + 1
loop
// check for C:\ and get the folder at the end if not
tv_1.selectitem(ll_child)

return 0

end function

public function string wf_extractparentdir (string arg_directory);// Cuts off the last folder name to give you the parent directory
integer c,li_len,li_pos
string ls_parent

// ie   c:\temp\temp2
// ie   c: or Desktop

li_len = LenA(arg_directory)
if isnull(li_len) then
	messagebox('Error','Parm to wf_extractparentdir was NULL.')
	return 'Null Value Passed'
end if

if arg_directory = 'Desktop' then 
	return 'Desktop'
end if

choose case li_len
	case 0
		messagebox('Error','No parm sent to wf_extractparentdir')
	case 2  // currently at drive root
		return 'Desktop'
	case is > 2
		for c = li_len to 1 step -1
			li_pos = PosA(arg_directory,'\',c)
			if li_pos > 0 then
				ls_parent = MidA(arg_directory,1,li_pos - 1)
				exit
			end if
		next
	case else
		return 'Error With Len(parm)'
end choose
return ls_parent
end function

public function integer wf_populate_listview (string arg_directory);integer li_len,li_pos,c,li
string ls_currdir
string ls_subdir

// called from wf_populate()
// takes in a directory and populates the list view with data about the passed directory
// use wf_extractparentdir to get the parent directory

setpointer(hourglass!)
// Populates the drive letter or the current subdirectory
choose case arg_directory
	case 'Desktop'  // populate all the drive letters
		ddlb_1.dirlist('*.*',16384)
		lv_files.deleteitems()
		li = ddlb_1.totalitems()
		if li > 0 then
			for c = 1 to li
				lv_files.additem(' (' + MidA(upper(ddlb_1.text(c)),3,1) + ':)',2)
			next
		else
			messagebox('Error','No drives were detected.',stopsign!)
		end if
	case 'Error',''
		messagebox('Error','Empty parm value passed to wf_populate.')
		plb_drives.reset()
		lv_files.deleteitems()
		return -1
	case else
		// Get and display the subdirectories of a valid folder
		if ddlb_1.dirlist(arg_directory + '\*.',16,st_dir) then
			li = ddlb_1.totalitems()
			lv_files.deleteitems()
			if li > 0 then
				for c = 1 to li
					ls_subdir = ddlb_1.text(c)
					if LeftA(ls_subdir,1) = '[' and RightA(ls_subdir,1) = ']' and ls_subdir <> '[..]' then
						ls_subdir = MidA(ls_subdir,2)
						li_len = LenA(ls_subdir)
						ls_subdir = MidA(ls_subdir,1,li_len - 1)
						If AscA(LeftA(ls_subdir,1)) >= 97 and AscA(LeftA(ls_subdir,1)) <= 122 Then
							ls_subdir = upper(LeftA(ls_subdir,1)) + MidA(ls_subdir,2)
						End If
						lv_files.additem(ls_subdir,1)
						p_back_off.post hide()
						p_back_up.post show()
					end if
				next
			end if
		else
			messagebox('Select','Could not find any folders under this directory.')
			return -2
		end if
end choose
return 0

end function

on w_getdirectory.create
this.p_dropdown=create p_dropdown
this.dw_1=create dw_1
this.sle_dir=create sle_dir
this.ddlb_1=create ddlb_1
this.cb_cancel=create cb_cancel
this.cb_1=create cb_1
this.st_1=create st_1
this.st_dir=create st_dir
this.p_back_up=create p_back_up
this.p_back_down=create p_back_down
this.p_back_off=create p_back_off
this.lv_files=create lv_files
this.plb_drives=create plb_drives
this.tv_1=create tv_1
this.Control[]={this.p_dropdown,&
this.dw_1,&
this.sle_dir,&
this.ddlb_1,&
this.cb_cancel,&
this.cb_1,&
this.st_1,&
this.st_dir,&
this.p_back_up,&
this.p_back_down,&
this.p_back_off,&
this.lv_files,&
this.plb_drives,&
this.tv_1}
end on

on w_getdirectory.destroy
destroy(this.p_dropdown)
destroy(this.dw_1)
destroy(this.sle_dir)
destroy(this.ddlb_1)
destroy(this.cb_cancel)
destroy(this.cb_1)
destroy(this.st_1)
destroy(this.st_dir)
destroy(this.p_back_up)
destroy(this.p_back_down)
destroy(this.p_back_off)
destroy(this.lv_files)
destroy(this.plb_drives)
destroy(this.tv_1)
end on

event open;//**** kEnn : 2001-02-14 *********************************************
//이 Window의 사용방법은 아래와 같다.											*
//string ls																				*
//openwithparm(w_getdirectory, "T" + "C:\")									*
//ls = message.stringparm															*
//********************************************************************
// Marc Mataya
// January 12, 1999
// This object will allow the user to select a drive letter and folder
// Returns:  string containing the full pathname

integer li,c,li_pos,li_len
boolean lb_usealtdrive
string ls_currdir,ls_subdir,ls_parm

// always starts with the current directory

// The user will set this variable as a parameter to this window
// ie.  openwithparm(w_getdirectory,'Tc:\program files'
ls_parm = message.stringparm
if LeftA(ls_parm,1) = 'T' then
	sle_dir.enabled = true
else
	sle_dir.enabled = false
end if

ddlb_1.DirList ('*.xxx',16,st_dir)
st_dir.text = upper(LeftA(st_dir.text,4)) + MidA(st_dir.text,5)
is_original_directory = st_dir.text

// was there a directory that was sent in?
ls_currdir = MidA(ls_parm,2)
if LenA(ls_currdir) > 0 then
	// chop off the uneccessary extension
	if RightA(ls_currdir,1) = '\' then
		ls_currdir = MidA(ls_currdir,1,LenA(ls_currdir) - 1)
	end if
	if fileexists(ls_currdir) then
		st_dir.text = ls_currdir
	else
		ddlb_1.DirList ('*.xxx',16,st_dir)
		//messagebox('Warning',"The previously specified directory does not exist.  This window will opened to the application's current directory.",information!)
	end if
else
	ddlb_1.DirList ('*.xxx',16,st_dir)
end if
is_selected_directory = st_dir.text

ddlb_1.visible = false
st_dir.visible = false
dw_1.visible = false
tv_1.visible = false

wf_initialize_treeview()
wf_populate(is_selected_directory)

end event

event close;// After the dialog opened reset the dir
ddlb_1.DirList(is_original_directory  + '\*.xxx',16,st_dir)
if is_return = '' or isnull(is_return) then
	closewithreturn(this,'')
end if

end event

event key;if key = keyEscape! then
	closewithreturn(this,'')
end if

end event

type p_dropdown from picture within w_getdirectory
integer x = 1687
integer y = 32
integer width = 78
integer height = 80
integer taborder = 80
boolean originalsize = true
string picturename = "dropdown.bmp"
boolean focusrectangle = false
end type

event clicked;tv_1.visible = not tv_1.visible
end event

type dw_1 from datawindow within w_getdirectory
integer x = 87
integer y = 800
integer width = 1024
integer height = 160
integer taborder = 50
string dataobject = "d_handles"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type sle_dir from singlelineedit within w_getdirectory
integer x = 27
integer y = 720
integer width = 1883
integer height = 80
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event getfocus;tv_1.visible = false
end event

type ddlb_1 from dropdownlistbox within w_getdirectory
integer x = 82
integer y = 836
integer width = 229
integer height = 88
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type cb_cancel from commandbutton within w_getdirectory
integer x = 1541
integer y = 824
integer width = 370
integer height = 96
integer taborder = 70
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
string text = "&Cancel"
end type

event clicked;is_return = ''
closewithreturn(parent,is_return)
end event

event getfocus;tv_1.visible = false
end event

type cb_1 from commandbutton within w_getdirectory
integer x = 1147
integer y = 824
integer width = 370
integer height = 96
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
string text = "&OK"
boolean default = true
end type

event clicked;if fileexists(sle_dir.text) then
	is_return = sle_dir.text
	closewithreturn(parent,is_return)
else
	messagebox('Select Directory','The directory listed in the edit box does not exist.',stopsign!)
	wf_populate(is_selected_directory)
end if

end event

event getfocus;tv_1.visible = false
end event

type st_1 from statictext within w_getdirectory
integer x = 46
integer y = 44
integer width = 224
integer height = 76
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
long backcolor = 67108864
boolean enabled = false
string text = "Look &in:"
boolean focusrectangle = false
end type

type st_dir from statictext within w_getdirectory
integer x = 59
integer y = 864
integer width = 142
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
long backcolor = 255
boolean enabled = false
string text = "none"
boolean focusrectangle = false
end type

event constructor;visible = false

end event

type p_back_up from picture within w_getdirectory
event _lbuttondown pbm_lbuttondown
event _lbuttonup pbm_lbuttonup
event _disableback ( )
integer x = 1801
integer y = 32
integer width = 105
integer height = 88
integer taborder = 100
boolean originalsize = true
string picturename = "back_up.bmp"
boolean focusrectangle = false
end type

event _lbuttondown;this.visible = false

end event

event _lbuttonup;integer li,c,li_pos
string ls_previous,ls_previous_full

this.visible = true
if (pointerX() < 106 and pointerX() > 0) and (pointerY() < 89 and pointerY() > 0) then
	// the mouse is somewhere on the button so continue
else
	return
end if

is_selected_directory = wf_extractparentdir(is_selected_directory)
wf_populate(is_selected_directory)
if is_selected_directory = 'Desktop' then
	post event _disableback()
end if

end event

event _disableback;p_back_up.visible = false
p_back_off.visible = true
p_back_off.show()

end event

event getfocus;tv_1.visible = false
end event

type p_back_down from picture within w_getdirectory
integer x = 1801
integer y = 32
integer width = 105
integer height = 88
boolean originalsize = true
string picturename = "back_down.bmp"
boolean focusrectangle = false
end type

type p_back_off from picture within w_getdirectory
integer x = 1801
integer y = 32
integer width = 105
integer height = 88
boolean originalsize = true
string picturename = "back_off.bmp"
boolean focusrectangle = false
end type

type lv_files from listview within w_getdirectory
integer x = 27
integer y = 140
integer width = 1883
integer height = 560
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean autoarrange = true
boolean fixedlocations = true
boolean labelwrap = false
listviewview view = listviewlist!
string largepicturename[] = {"folderclosed.bmp"}
integer largepicturewidth = 32
integer largepictureheight = 32
long largepicturemaskcolor = 553648127
string smallpicturename[] = {"folderclosed.bmp","drive.bmp"}
integer smallpicturewidth = 16
integer smallpictureheight = 16
long smallpicturemaskcolor = 553648127
long statepicturemaskcolor = 553648127
end type

event doubleclicked;string ls_fulldir
listviewitem llvi

if index < 1 then return

// take this selected subdirectory (folder), append it, and drill down deeper
lv_files.getitem ( index, llvi)

if LeftA(llvi.label,2) = ' (' then
	// it's a drive letter
	is_selected_directory = MidA(llvi.label,3,2)
else
	is_selected_directory = is_selected_directory + '\' + llvi.label
end if

wf_populate(is_selected_directory)


end event

event getfocus;tv_1.visible = false

end event

type plb_drives from picturelistbox within w_getdirectory
event _lbuttondown pbm_lbuttondown
integer x = 270
integer y = 32
integer width = 1499
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean disablenoscroll = true
string picturename[] = {"desktop.bmp","drive.bmp","folderclosed.bmp","folderopened.bmp"}
long picturemaskcolor = 553648127
end type

event _lbuttondown;tv_1.visible = not tv_1.visible
if tv_1.visible = true then 
	tv_1.post setfocus()
else
	lv_files.post setfocus()
end if
plb_drives.post selectitem(0)


end event

type tv_1 from treeview within w_getdirectory
integer x = 270
integer y = 108
integer width = 1499
integer height = 660
integer taborder = 90
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = variable!
fontfamily fontfamily = modern!
string facename = "새굴림"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean haslines = false
boolean hideselection = false
string picturename[] = {"desktop.bmp","drive.bmp","folderclosed.bmp","folderopened.bmp"}
long picturemaskcolor = 553648127
long statepicturemaskcolor = 536870912
end type

event clicked;// this is to become the new folder, it's subdir's will show in the listview

treeviewitem ltvi
string ls_dir,ls_selected
long ll_parent
integer li_pictureindex

//getitem(handle,ltvi)

// 1st, get this folder name
//ls_selected = ltvi.label

// get the full path from the datawindow by search for the handle
ls_dir = wf_getdirfromhandle(handle)

//// get the full path selected by traversing the treeview backwards
//ll_parent = handle
//do until ll_parent = 1
//	getitem(ll_parent,ltvi)
//	// if the parent is now the Desktop
//	choose case ltvi.level
//		case 1
//			// reached the desktop level
//			ls_dir = 'Desktop'
//			exit
//		case 2  // this is a drive label ' (C:\)'
//			if len(ls_dir) > 0 then
//				ls_dir = mid(ltvi.label,3,2) + '\' + ls_dir
//			else
//				ls_dir = mid(ltvi.label,3,2)
//			end if
//		case is > 2  // this is a folder
//			ls_dir = ltvi.label + '\' + ls_dir
//	end choose
//	ll_parent = finditem(ParentTreeItem!,ll_parent)
//loop

tv_1.visible = false

wf_populate(ls_dir)

end event

