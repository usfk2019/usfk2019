$PBExportHeader$w_file_download.srw
$PBExportComments$프로그램 Local  Down
forward
global type w_file_download from window
end type
type cb_open from commandbutton within w_file_download
end type
type cb_down from commandbutton within w_file_download
end type
type sle_cnt from singlelineedit within w_file_download
end type
type hpb_progress from hprogressbar within w_file_download
end type
type p_1 from picture within w_file_download
end type
end forward

global type w_file_download from window
integer width = 2295
integer height = 1508
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_open cb_open
cb_down cb_down
sle_cnt sle_cnt
hpb_progress hpb_progress
p_1 p_1
end type
global w_file_download w_file_download

type variables
Private :
 Boolean ib_dbconnected = False //DB 접속 여부
 Boolean ib_exit = False       //Window종료여부

 u_cust_db_app iu_cust_db_app //db조작처리
 Boolean ib_open = False

string is_down_ok
end variables

on w_file_download.create
this.cb_open=create cb_open
this.cb_down=create cb_down
this.sle_cnt=create sle_cnt
this.hpb_progress=create hpb_progress
this.p_1=create p_1
this.Control[]={this.cb_open,&
this.cb_down,&
this.sle_cnt,&
this.hpb_progress,&
this.p_1}
end on

on w_file_download.destroy
destroy(this.cb_open)
destroy(this.cb_down)
destroy(this.sle_cnt)
destroy(this.hpb_progress)
destroy(this.p_1)
end on

event open;string ls_path
Int		li_sw = 0

iu_cust_db_app = Create u_cust_db_app

//Title 설정
This.Title = "Version Management"

// Window를 화면 중앙에 ...
f_center_window(w_file_download)


//***** ini file일 존재하는 directory검색 *****
ls_path = gs_ini_file
If Not FileExists(ls_path) Then
	f_msg_usr_err_app(610, This.Title, ls_path)
	Return
End If

//DATABASE ProfileString Setting
gs_database = Upper(ProfileString(ls_path, "database", "database", "ORACLE"))
//GS_PRN 		= Upper(ProfileString(ls_path, "POS", 		"PRN", "COM1;6;2;0"))
//GS_DSP 		= Upper(ProfileString(ls_path, "POS", 		"DSP", "COM2;6;2;0"))

//***** check db is connected, If not, connect *****
If NOT ib_dbconnected Then
	//해당 DB로 Connect
	iu_cust_db_app.is_caller = "CONNECT"
	iu_cust_db_app.is_title = This.Title
   iu_cust_db_app.is_data[2] = ""
	iu_cust_db_app.is_data[1] = gs_database
	iu_cust_db_app.is_data[2] = gs_ini_file
   iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		Return
	ELSE
		ib_dbconnected = TRUE
	End If
End If


cb_down.PostEvent(clicked!)
end event

type cb_open from commandbutton within w_file_download
boolean visible = false
integer x = 1701
integer y = 1312
integer width = 343
integer height = 104
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Open"
end type

event clicked;if is_down_ok = 'OK' then
	open(w_login_1)
	close(parent)
end if
end event

type cb_down from commandbutton within w_file_download
boolean visible = false
integer x = 1353
integer y = 1312
integer width = 343
integer height = 104
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Down"
end type

event clicked;string ls_down_path, ls_downdt, ls_file_id, ls_down_pro_path, ls_create_path, ls_mod_path, ls_rep_path
long   ll_cnt, ll_seq, ll_size, ll_write_file, ll_start
int    li_loop, ii, file_ok, li_pos, jj
blob   lb_file, lb_piece
boolean dir_ok

ls_downdt = ProFileString(gs_ini_file, "VERSION", "UPDATEDOWN_DT","")

if len(ls_downdt) < 6 then ls_downdt = '20000101000000'

SELECT REF_CONTENT || '\'
  INTO :ls_down_path
  FROM SYSCTL1T
 WHERE MODULE = 'V0'
   AND REF_NO = 'VER1';

// Test를 위해서 임시로....
//ls_down_path = 'C:\TNC_TEST\UBS10\'

SELECT COUNT(*)
  INTO :ll_cnt
  FROM SYSPGM_VER
 WHERE FILE_DT > :ls_downdt;

sle_cnt.text = '1 / ' + string(ll_cnt)

hpb_progress.Position = 1

if len(ls_down_path) > 0 then
	FOR jj = 0 to len(ls_down_path)
		if jj = 0 then // 처음 시작시
			li_pos = pos(ls_down_path,'\')
			ls_create_path = mid(ls_down_path, 1, li_pos)
		else
			li_pos = pos(ls_rep_path, '\')
			ls_create_path = mid(ls_rep_path, 1, li_pos)
		end if
		
		if li_pos = 0 then exit
		
		if ls_create_path = 'C:\' then
			ls_rep_path = mid(ls_down_path, li_pos + 1, 999)
			ls_mod_path = ls_create_path
		else
			ls_mod_path = ls_mod_path + mid(ls_create_path, 1, len(ls_create_path) - 1) //DIR 생성시 마지막 '\'를 빼고 
			if DirectoryExists(ls_mod_path) = false then
				CreateDirectory(ls_mod_path)
			end if
			ls_mod_path = ls_mod_path + '\'
			ls_rep_path = mid(ls_rep_path, li_pos + 1, 999)
		end if
		
		jj++
	NEXT
end if


DECLARE DOWN_CUR CURSOR FOR
	SELECT FILE_ID
	  FROM SYSPGM_VER
	 WHERE FILE_DT > :ls_downdt;
	 
OPEN DOWN_CUR;

FETCH DOWN_CUR INTO :ls_file_id;

DO WHILE sqlca.sqlcode = 0
	ll_seq++
	
	sle_cnt.text = string(ll_seq) + ' / ' + string(ll_cnt) + ' ' + ls_file_id + ' Downloading...'

	SELECTBLOB FILE_DATA
	      INTO :lb_file
			FROM SYSPGM_VER
		  WHERE FILE_ID = :ls_file_id;

	if sqlca.sqlcode <> 0 then
		messagebox("오류","File Downloading 중 오류가 발생하였습니다.", StopSign!)
		CLOSE DOWN_CUR;
	end if
	
	ls_down_pro_path = ls_down_path + '\' + ls_file_id
	
//	if FileExists(ls_down_path + '\' + ls_file_id) = false then
//		CreateDirectory(ls_down_path + '\' + ls_file_id)
//	end if

	dir_ok = DirectoryExists(ls_down_path)

	if dir_ok = false then
		file_ok = CreateDirectory(ls_down_path)
	end if
	
	ll_size       = len(lb_file)
//	ll_write_file = FileOpen(ls_down_path + '\' + ls_file_id, StreamMode!, Write!, LockReadWrite!, Replace!)
	ll_write_file = FileOpen(ls_down_pro_path, StreamMode!, Write!, LockReadWrite!, Replace!)
	li_loop       = ll_size / 32765
	ll_start      = 1
	
	for ii = 1 to li_loop
		lb_piece = blobmid(lb_file, ll_start, 32765)
		ll_start = ll_start + 32765
		FileWrite(ll_write_file, lb_piece)
	next

	lb_piece = blobmid(lb_file, ll_start, ll_size - (ll_start - 1))
	
	FileWrite(ll_write_file, lb_piece)
	FileClose(ll_write_file)
	
	sle_cnt.text = string(ll_seq) + ' / ' + string(ll_cnt)

	hpb_progress.Position = (ll_seq / ll_cnt * 100)
	
	
	FETCH DOWN_CUR INTO :ls_file_id;
LOOP

CLOSE DOWN_CUR;

SetProfileString(gs_ini_file, "VERSION", "UPDATEDOWN_DT", string(today(),'yyyymmddhhmmss'))


is_down_ok = 'OK'
cb_open.PostEvent(clicked!)


end event

type sle_cnt from singlelineedit within w_file_download
integer x = 5
integer y = 1248
integer width = 974
integer height = 80
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type hpb_progress from hprogressbar within w_file_download
integer x = 1038
integer y = 1248
integer width = 1207
integer height = 76
unsignedinteger maxposition = 100
integer setstep = 10
end type

type p_1 from picture within w_file_download
integer x = 14
integer y = 8
integer width = 2226
integer height = 1240
boolean originalsize = true
string picturename = "download.jpg"
boolean focusrectangle = false
end type

