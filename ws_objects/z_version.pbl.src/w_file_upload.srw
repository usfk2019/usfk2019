$PBExportHeader$w_file_upload.srw
$PBExportComments$PBD등 프로그램 DB 저장(Upload)
forward
global type w_file_upload from window
end type
type cb_4 from commandbutton within w_file_upload
end type
type cb_3 from commandbutton within w_file_upload
end type
type cb_2 from commandbutton within w_file_upload
end type
type dw_up_file from datawindow within w_file_upload
end type
type ddlb_div from dropdownlistbox within w_file_upload
end type
type st_3 from statictext within w_file_upload
end type
type cb_1 from commandbutton within w_file_upload
end type
type st_2 from statictext within w_file_upload
end type
type st_1 from statictext within w_file_upload
end type
type sle_path from singlelineedit within w_file_upload
end type
type cb_find from commandbutton within w_file_upload
end type
type lb_1 from listbox within w_file_upload
end type
type gb_1 from groupbox within w_file_upload
end type
end forward

global type w_file_upload from window
integer width = 4754
integer height = 1980
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 29478337
string icon = "AppIcon!"
boolean center = true
cb_4 cb_4
cb_3 cb_3
cb_2 cb_2
dw_up_file dw_up_file
ddlb_div ddlb_div
st_3 st_3
cb_1 cb_1
st_2 st_2
st_1 st_1
sle_path sle_path
cb_find cb_find
lb_1 lb_1
gb_1 gb_1
end type
global w_file_upload w_file_upload

type variables
int ii_row
end variables

on w_file_upload.create
this.cb_4=create cb_4
this.cb_3=create cb_3
this.cb_2=create cb_2
this.dw_up_file=create dw_up_file
this.ddlb_div=create ddlb_div
this.st_3=create st_3
this.cb_1=create cb_1
this.st_2=create st_2
this.st_1=create st_1
this.sle_path=create sle_path
this.cb_find=create cb_find
this.lb_1=create lb_1
this.gb_1=create gb_1
this.Control[]={this.cb_4,&
this.cb_3,&
this.cb_2,&
this.dw_up_file,&
this.ddlb_div,&
this.st_3,&
this.cb_1,&
this.st_2,&
this.st_1,&
this.sle_path,&
this.cb_find,&
this.lb_1,&
this.gb_1}
end on

on w_file_upload.destroy
destroy(this.cb_4)
destroy(this.cb_3)
destroy(this.cb_2)
destroy(this.dw_up_file)
destroy(this.ddlb_div)
destroy(this.st_3)
destroy(this.cb_1)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.sle_path)
destroy(this.cb_find)
destroy(this.lb_1)
destroy(this.gb_1)
end on

event open;//lb_1.dirlist("C:\BILLPRO_3.0_UBS10.0_DEV\Source(pbl)\*.pbd", 0)

sle_path.text = GetCurrentDirectory() + '\'
ddlb_div.text = '*'

dw_up_file.SetTransObject(SQLCA)
dw_up_file.Retrieve()
end event

type cb_4 from commandbutton within w_file_upload
integer x = 4096
integer y = 100
integer width = 343
integer height = 104
integer taborder = 90
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "종료"
end type

event clicked;close(w_file_upload)
end event

type cb_3 from commandbutton within w_file_upload
integer x = 3666
integer y = 100
integer width = 343
integer height = 104
integer taborder = 100
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "저장"
end type

event clicked;int      ii, li_chk, li_rtn, li_sfile, li_process_cnt
string   ls_file_dt, ls_file_id, ls_file_path, ls_file_name
datetime ldt_dt
long     ll_flen, ll_offset, ll_read
blob     lb_save, lb_read


if dw_up_file.RowCount() < 1 then return

ls_file_dt = string(today(),'yyyymmddhhmmss')
ldt_dt     = datetime(date(today()), time(today()))

SetPointer(HourGlass!)

FOR ii = 1 to dw_up_file.RowCount()
	li_chk = dw_up_file.Object.chk[ii]
	
	if li_chk = 1 then
		dw_up_file.Object.file_dt  [ii] = ls_file_dt
		dw_up_file.Object.crt_user [ii] = 'TNC'
		if isnull(dw_up_file.Object.crtdt[ii]) then
			dw_up_file.Object.crtdt [ii] = ldt_dt
		end if
		dw_up_file.Object.updt_user[ii] = 'TNC'
		dw_up_file.Object.updtdt   [ii] = ldt_dt
		
		li_process_cnt++
		
	end if
NEXT

if li_process_cnt < 1 then
	Messagebox("확인","Upload할 파일을 선택후 저장하세요!")
	SetPointer(Arrow!)
	return
end if

li_rtn = dw_up_file.Update()

if li_rtn = 1 then
	FOR ii = 1 to dw_up_file.RowCount()
		li_chk = dw_up_file.Object.chk[ii]
		
		if li_chk = 1 then
			ls_file_id   = dw_up_file.Object.file_id  [ii]
			ls_file_path = dw_up_file.Object.file_path[ii]
			
			ls_file_name = ls_file_path + ls_file_id
			
			ll_flen = FileLength(ls_file_name)
			if ll_flen > 0 then
				li_sfile = FileOpen(ls_file_name, StreamMode!, read!)
				ll_offset = 0
				do while (ll_flen > 0)
					FileSeek(li_sfile, ll_offset, FromBeginning!)
					ll_read = FileRead(li_sfile, lb_read)
					lb_save = lb_save + lb_read
					
					if ll_read > 0 then
						ll_flen   = ll_flen - ll_read
						ll_offset = ll_offset + ll_read
					else
						ll_flen = 0
					end if
				loop
				
				FileClose(li_sfile)
				
				UPDATEBLOB SYSPGM_VER
					    SET FILE_DATA = :lb_save
				     WHERE file_id   = :ls_file_id;
			end if
		end if
	NEXT
	
end if

if sqlca.sqlcode = 0 then
	Messagebox("확인","자료 Upload 완료")
	Commit;
	dw_up_file.Retrieve()
else
	Messagebox("에러","자료 Upload 오류")
	Rollback;
end if

SetPointer(Arrow!)
end event

type cb_2 from commandbutton within w_file_upload
integer x = 933
integer y = 908
integer width = 210
integer height = 104
integer taborder = 60
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "<=="
end type

event clicked;if Messagebox("확인", dw_up_file.GetItemString(ii_row, 'file_id') + '을 삭제하시겠습니까?', Exclamation!, OkCancel!, 2) = 1 then
	dw_up_file.deleterow(ii_row)
end if
end event

type dw_up_file from datawindow within w_file_upload
integer x = 1179
integer y = 300
integer width = 3429
integer height = 1516
integer taborder = 30
string title = "none"
string dataobject = "dw_file_upload_tgt"
boolean hscrollbar = true
boolean vscrollbar = true
boolean hsplitscroll = true
boolean livescroll = true
end type

event clicked;int ii

if row < 1 then return

FOR ii = 1 to this.RowCount()
	This.SelectRow(ii, false)
next

ii_row = row
This.selectrow(row, true)
end event

type ddlb_div from dropdownlistbox within w_file_upload
integer x = 2734
integer y = 92
integer width = 311
integer height = 376
integer taborder = 80
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string item[] = {"pbd","exe","*"}
borderstyle borderstyle = stylelowered!
end type

event selectionchanged;string ls_path, ls_fix_div

if ddlb_div.text = '*' then
	ls_fix_div = '*.*'
elseif ddlb_div.text = 'pbd' then
	ls_fix_div = '*.pbd'
elseif ddlb_div.text = 'exe'then
	ls_fix_div = '*.exe'
end if

ls_path = sle_path.text

//lb_1.dirlist("C:\BILLPRO_3.0_UBS10.0_DEV\Source(pbl)\*.pbd", 0)
lb_1.dirlist(ls_path + ls_fix_div, 0)
end event

type st_3 from statictext within w_file_upload
integer x = 2423
integer y = 104
integer width = 343
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Division"
alignment alignment = center!
boolean focusrectangle = false
end type

type cb_1 from commandbutton within w_file_upload
integer x = 933
integer y = 776
integer width = 210
integer height = 104
integer taborder = 40
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "==>"
end type

event clicked;string ls_filename, ls_path
integer Total, n, ll_find_row
//ls_name = lb_1.selecteditem()
//ls_name = lb_1.Text(index)
//messagebox(string(index), ls_name)

ls_path = sle_path.text // File Path

Total = lb_1.TotalItems()

FOR n = 1 to Total
	IF lb_1.State(n) = 1 THEN // ListBox Item이 선택된 Row의 경우
		ls_filename = lb_1.text(n) // 선택된 File 명
		
		ll_find_row = dw_up_file.Find("file_id = '" + ls_filename + "'", 1, dw_up_file.RowCount())
		
		// 기 존재 여부 확인
		if ll_find_row > 0 then
			dw_up_file.Object.chk      [ll_find_row] = 1
			dw_up_file.Object.file_path[ll_find_row] = ls_path
			
		else
			dw_up_file.InsertRow(0)
			dw_up_file.Object.file_id  [dw_up_file.RowCount()] = ls_filename
			dw_up_file.Object.file_path[dw_up_file.RowCount()] = ls_path
			dw_up_file.Object.chk      [dw_up_file.RowCount()] = 1
		end if
	end if

NEXT

end event

type st_2 from statictext within w_file_upload
integer x = 146
integer y = 300
integer width = 768
integer height = 72
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 12639424
string text = "File Name"
alignment alignment = center!
boolean border = true
boolean focusrectangle = false
end type

type st_1 from statictext within w_file_upload
integer x = 174
integer y = 104
integer width = 261
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "File Path"
alignment alignment = center!
boolean focusrectangle = false
end type

type sle_path from singlelineedit within w_file_upload
integer x = 439
integer y = 92
integer width = 1966
integer height = 92
integer taborder = 70
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type cb_find from commandbutton within w_file_upload
integer x = 3273
integer y = 88
integer width = 251
integer height = 104
integer taborder = 50
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Find"
end type

event clicked;string ls_docpath, ls_docname[], ls_path, ls_div, ls_fix_div
integer i, li_cnt, li_rtn, li_filenum
integer li_pos

li_rtn = GetFileOpenName("Select File", ls_docpath, ls_docname[], "DOC", + "PBD Files (*.PBD),*.pbd," + "EXE Files (*.EXE),*.exe," + "All Files (*.*), *.*", "C:\BILLPRO_3.0_UBS10.0_DEV",18)

ls_div = ddlb_div.text

if ls_div = '*' then
	ls_fix_div = '*.*'
elseif ls_div = 'pbd' then
	ls_fix_div = '*.pbd'
elseif ls_div = 'exe' then
	ls_fix_div = '*.exe'
end if

li_pos = lastpos(ls_docpath,'\')

sle_path.text = mid(ls_docpath, 1, li_pos)
ls_path = mid(ls_docpath, 1, li_pos) + ls_fix_div

//lb_1.dirlist("C:\BILLPRO_3.0_UBS10.0_DEV\Source(pbl)\*.pbd", 0)
lb_1.dirlist(ls_path, 0)
end event

type lb_1 from listbox within w_file_upload
integer x = 146
integer y = 380
integer width = 768
integer height = 1436
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean multiselect = true
borderstyle borderstyle = stylelowered!
boolean extendedselect = true
end type

event doubleclicked;string ls_name
//ls_name = lb_1.selecteditem()

ls_name = lb_1.Text(index)
//messagebox(string(index), ls_name)


integer Total, n
Total = lb_1.TotalItems()

FOR n = 1 to Total
	IF lb_1.State(n) = 1 THEN // ListBox Item이 선택된 Row의 경우
		MessageBox("Selected Item", lb_1.text(n))
	end if

NEXT

end event

type gb_1 from groupbox within w_file_upload
integer x = 146
integer y = 16
integer width = 3419
integer height = 228
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

