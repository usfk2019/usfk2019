$PBExportHeader$w_mdi_main.srw
forward
global type w_mdi_main from window
end type
type mdi_1 from mdiclient within w_mdi_main
end type
type st_resize from statictext within w_mdi_main
end type
type tv_menu from u_tv_a_hirachy within w_mdi_main
end type
end forward

global type w_mdi_main from window
integer x = 9
integer y = 4
integer width = 6222
integer height = 3684
boolean titlebar = true
string title = "Untitled"
string menuname = "m_mdi_main"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowtype windowtype = mdi!
windowstate windowstate = maximized!
long backcolor = 29478337
mdi_1 mdi_1
st_resize st_resize
tv_menu tv_menu
end type
global w_mdi_main w_mdi_main

type prototypes
//Wave 파일 연주 하기 위함
Function Boolean sndPlaySoundA(String s_file, UINT u_flags) Library "WINMM.dll" alias for "sndPlaySoundA;Ansi"
Function UINT LoadLibraryA(String as_library) Library "kernel32" alias for "LoadLibraryA;Ansi"
Subroutine FreeLibrary(UINT HInstance) Library "kernel32"
end prototypes

type variables
DataStore ids_source

//drag & drop으로 크기 조정을 위한 마우스 이동유무
Boolean ib_mouse_move
//기존의 마우스 위치 저장
int ii_old_mouse_x
//close시 질의 유무
Boolean ib_quiet = False

//pgm menu, pgm auth, grp auth를 위한 DataStore
DataStore ids_pgm_menu, ids_pgm_auth, ids_grp_auth, ids_pgm_menu1

//For selected TreeViewItem
Long il_selected_handle

//C.BORA 2003.08.14
String is_pgm_id

//Timer 위한
String is_reqactive
String is_reqterm
String is_beep_yn, is_beep_status, is_beep_time


end variables

forward prototypes
public function integer wfi_get_auth (string as_user_id, string as_pgm_id)
public function integer wfi_get_low_auth (string as_user_id, string as_pgm_id)
public function integer fi_play (string as_wave)
end prototypes

public function integer wfi_get_auth (string as_user_id, string as_pgm_id);//목적 : 사용자의 authority를 구함
//인자 : as_user_id - User ID, as_pgm_id - Program ID
//참고 : as_user_id는 지금은 사용 않고 있다.

String ls_filter, ls_tmp_pgm_id, ls_p_pgm_id
Int li_auth = -1

ls_filter = "pgm_id = '" + as_pgm_id + "'"
ids_pgm_auth.SetFilter(ls_filter)
ids_pgm_auth.Filter()

If ids_pgm_auth.RowCount() > 0 Then		//Program Authority가 존재할 경우
	li_auth = ids_pgm_auth.Object.auth[1]
Else
	ls_tmp_pgm_id = as_pgm_id
	//Program의 Group ID를 구하기
	Do While True
		ls_filter = "pgm_id = '" + ls_tmp_pgm_id + "'"
		ids_pgm_menu.SetFilter(ls_filter)
		ids_pgm_menu.Filter()
		If ids_pgm_menu.RowCount() > 0 Then
			ls_p_pgm_id = ids_pgm_menu.Object.p_pgm_id[1]

			If IsNull(ls_p_pgm_id) Then Exit

			ls_filter = "group_id = '" + ls_p_pgm_id + "'"
			ids_grp_auth.SetFilter(ls_filter)
			ids_grp_auth.Filter()
			If ids_grp_auth.RowCount() > 0 Then		//Group Authority가 존재할 경우
				li_auth = ids_grp_auth.Object.auth[1]
				Exit
			End If

			If ls_p_pgm_id = ls_tmp_pgm_id Then		//추후 Cross Link도 Check필요
				Exit
			End If
		Else			//Root로 가지 않는 경우
			Exit
		End If
		ls_tmp_pgm_id = ls_p_pgm_id
	Loop


End If

Return li_auth

end function

public function integer wfi_get_low_auth (string as_user_id, string as_pgm_id);//목적 : 사용자의 authority를 구함
//인자 : as_user_id - User ID, as_pgm_id - Program ID
//참고 : as_user_id는 지금은 사용 않고 있다.

String ls_filter, ls_tmp_pgm_id, ls_p_pgm_id, ls_item_type, ls_pgm_id
Int li_auth = -1, li_row, li_row1
Boolean lb_exit = False, lb_exit1 = False

//Messagebox('1', as_pgm_id)
ls_filter = "pgm_id = '" + as_pgm_id + "'"
ids_pgm_auth.SetFilter(ls_filter)
ids_pgm_auth.Filter()

If ids_pgm_auth.RowCount() > 0 Then		//Program Authority가 존재할 경우
	li_auth = ids_pgm_auth.Object.auth[1]
Else
	
	ls_tmp_pgm_id = as_pgm_id
			
	Do While True
		ls_filter = "pgm_id = '" + ls_tmp_pgm_id + "'"
		ids_pgm_menu.SetFilter(ls_filter)
		ids_pgm_menu.Filter()
		If ids_pgm_menu.RowCount() > 0 Then
			ls_p_pgm_id = ids_pgm_menu.Object.p_pgm_id[1]

			If IsNull(ls_p_pgm_id) Then Exit
			
			//Program의 Group ID를 구하기
			ls_filter = "group_id = '" + ls_tmp_pgm_id + "'"
			ids_grp_auth.SetFilter(ls_filter)
			ids_grp_auth.Filter()
			If ids_grp_auth.RowCount() > 0 Then		//Group Authority가 존재할 경우
				li_auth = ids_grp_auth.Object.auth[1]
				Exit
			Else
				ls_filter = "p_pgm_id = '" + as_pgm_id + "'"
				ids_pgm_menu.SetFilter(ls_filter)
				ids_pgm_menu.Filter()
				If ids_pgm_menu.RowCount() > 0 Then
					For li_row = 1 To ids_pgm_menu.RowCount()
						ls_tmp_pgm_id = ids_pgm_menu.Object.pgm_id[li_row]
						ls_item_type = Trim(ids_pgm_menu.Object.item_type[li_row])
						If ls_item_type = "M" Then
							ls_filter = "group_id = '" + ls_tmp_pgm_id + "'"
							ids_grp_auth.SetFilter(ls_filter)
							ids_grp_auth.Filter()
							If ids_grp_auth.RowCount() > 0 Then
								li_auth = ids_grp_auth.Object.auth[1]
								lb_exit = True
							Else
								ls_filter = "p_pgm_id = '" + ls_tmp_pgm_id + "'"
								ids_pgm_menu1.SetFilter(ls_filter)
								ids_pgm_menu1.Filter()
								If ids_pgm_menu1.RowCount() > 0 Then
									For li_row1 = 1 To ids_pgm_menu1.RowCount()
										ls_pgm_id = ids_pgm_menu1.Object.pgm_id[li_row1]
										ls_item_type = ids_pgm_menu1.Object.item_type[li_row1]
										If ls_item_type = "M" Then
											ls_filter = "group_id = '" + ls_pgm_id + "'"
											ids_grp_auth.SetFilter(ls_filter)
											ids_grp_auth.Filter()
											If ids_grp_auth.RowCount() > 0 Then
												li_auth = ids_grp_auth.Object.auth[1]
												lb_exit1 = True
											End If
										ElseIf ls_item_type = "P" Then
											ls_filter = "pgm_id = '" + ls_pgm_id + "'"
											ids_pgm_auth.SetFilter(ls_filter)
											ids_pgm_auth.Filter()
											If ids_pgm_auth.RowCount() > 0 Then
												li_auth = ids_pgm_auth.Object.auth[1]
												lb_exit1 = True
											End If
										End If
									Next
								End If
								
								If lb_exit1 = True Then
									lb_exit = True
								End If
							End If
						ElseIf ls_item_type = "P" Then
							ls_filter = "pgm_id = '" + ls_tmp_pgm_id + "'"
							ids_pgm_auth.SetFilter(ls_filter)
							ids_pgm_auth.Filter()
							If ids_pgm_auth.RowCount() > 0 Then
								li_auth = ids_pgm_auth.Object.auth[1]
								lb_exit = True
							End If
						End If
					Next
				End If
				
				If lb_exit = True Then
					Exit
				End If
			End If
			
			If ls_p_pgm_id = ls_tmp_pgm_id Then		//추후 Cross Link도 Check필요
				Exit
			End If
				
		Else			//Root로 가지 않는 경우
			Exit
		End If
		ls_tmp_pgm_id = ls_p_pgm_id
	Loop

End If

Return li_auth
end function

public function integer fi_play (string as_wave);/*------------------------------------------------------------------------	
	Name	: fi_play
	Desc.	: Wave File 연주
	Arge.	: Stirng as_wavefile
	Return : -1 Error
				0	Success
---------------------------------------------------------------------------*/
UINT lu_instance

lu_instance = LoadLibraryA("WINMM.dll")
IF lu_instance = 0 THEN
	sndPlaySoundA(as_wave, 0)
	FreeLibrary(lu_instance)		//라이브러리 해지
Else
	Return - 1
END IF

return 0
end function

on w_mdi_main.create
if this.MenuName = "m_mdi_main" then this.MenuID = create m_mdi_main
this.mdi_1=create mdi_1
this.st_resize=create st_resize
this.tv_menu=create tv_menu
this.Control[]={this.mdi_1,&
this.st_resize,&
this.tv_menu}
end on

on w_mdi_main.destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.mdi_1)
destroy(this.st_resize)
destroy(this.tv_menu)
end on

event open;Int li_chg_width, li_sec
String ls_temp, ls_beep_temp[], ls_ref_desc

//Process DataStore
ids_pgm_menu = Create DataStore
ids_pgm_auth = Create DataStore
ids_grp_auth = Create DataStore

ids_pgm_menu1 = Create DataStore

ids_pgm_menu.DataObject = "d_dts_pgm_menu"   //syspgm1t
ids_pgm_auth.DataObject = "d_dts_pgm_auth"   //sysusr2t
ids_grp_auth.DataObject = "d_dts_grp_auth"   //sysusr3t

ids_pgm_menu1.DataObject = "d_dts_pgm_menu1"

ids_pgm_menu.SetTransObject(SQLCA)
ids_pgm_auth.SetTransObject(SQLCA)
ids_grp_auth.SetTransObject(SQLCA)

ids_pgm_menu1.SetTransObject(SQLCA)

ids_pgm_menu.Retrieve()
ids_pgm_auth.Retrieve(gs_user_id)
ids_grp_auth.Retrieve(gs_user_id)

ids_pgm_menu1.Retrieve()

integer lw, lh, lx, ly, tvw, tvx, tvy
lw = This.WorkSpaceWidth( )
lh = This.WorkSpaceHeight( )
lx = This.WorkspaceX( )
ly = This.WorkspaceY( )
tvx = tv_menu.X 
tvy = tv_menu.Y 
tvw = tv_menu.Width





//Set appreance

st_resize.X 	= tv_menu.X + tv_menu.Width
li_chg_width 	= tv_menu.X + tv_menu.Width + st_resize.Width

st_resize.Height 	= This.WorkSpaceHeight()
tv_menu.Height 	= This.WorkSpaceHeight() - tv_menu.Y * 2

//by jsj
//mdi_1.Move(li_chg_width, This.WorkSpaceY())
//mdi_1.Resize(This.WorkSpaceWidth() - li_chg_width, This.WorkSpaceHeight())

//by jsj
st_resize.Hide()
tv_menu.show()
m_mdi_main.m_start.TriggerEvent(Clicked!)
m_mdi_main.ib_visible = True

//timer코드값:작동여부;작동시간(초);작동서비스상태코드
ls_ref_desc 	= ""
ls_temp 			= fs_get_control("Z1", "A101", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_beep_temp[])		
is_beep_yn 		= ls_beep_temp[1]
is_beep_time 	= ls_beep_temp[2]
is_beep_status = ls_beep_temp[3]

If is_beep_yn = 'Y' Then
   Timer(integer(is_beep_time))
End IF

//this.title = 
//POS장비 Set & Display 
//F_INIT_DSP()
end event

event resize;Int li_chg_width
Int li_h, li_w, li_x, li_y

li_chg_width = tv_menu.X + tv_menu.Width //+ st_resize.Width <== 이상하지만, 존재시 여백 존재

li_h = This.WorkSpaceHeight()
li_w = This.WorkSpaceWidth()
li_x = This.WorkSpaceX()
li_y = This.WorkSpaceY()

//by jsj
//mdi_1.Resize(li_w - li_chg_width, li_h + li_y)
mdi_1.Resize(li_w , li_h + li_y)
//

tv_menu.Height = li_h - tv_menu.Y * 2

//by jsj
st_resize.Height = li_h - st_resize.Y * 2
//by jsj
end event

event closequery;//***** Ask for closing or not *****
Int li_net

If Not ib_quiet Then
//	Return 0
//Else
	li_net = MessageBox(gs_title, "It will close this program - "  + gs_title, + &
			Information!, OKCancel!)

	If li_net <> 1 Then Return 1
End If

end event

event close;//***** Processing before close *****
u_cust_db_app lu_cust_db_app
DateTime ldt_logout

lu_cust_db_app = Create u_cust_db_app

//Read today & current time
lu_cust_db_app.is_caller = "NOW"
lu_cust_db_app.is_title = This.Title

lu_cust_db_app.uf_prc_db()

If lu_cust_db_app.ii_rc = -1 Then Return

ldt_logout = lu_cust_db_app.idt_data[1]

//Record logout time
lu_cust_db_app.is_caller = "Record Logout-Time"
lu_cust_db_app.is_title = This.Title

lu_cust_db_app.is_data[1] = gs_user_id
lu_cust_db_app.idt_data[1] = ldt_logout

lu_cust_db_app.uf_prc_db()

If lu_cust_db_app.ii_rc = -1 Then Return

//Disconnect from db
lu_cust_db_app.is_caller = "DISCONNECT"
lu_cust_db_app.is_title = This.Title

lu_cust_db_app.uf_prc_db()

Destroy lu_cust_db_app

//***** 생성된 객체를 제거 *****
Destroy ids_pgm_menu
Destroy ids_pgm_auth
Destroy ids_grp_auth

end event

event timer;//kem
//Timer setting
Integer li_rc
c0u_dbmgr 	lu_dbmgr
lu_dbmgr = create c0u_dbmgr

lu_dbmgr.is_caller = "w_mdi_main%timer_active"
lu_dbmgr.is_data[1] = is_beep_status

lu_dbmgr.uf_prc_db()
If lu_dbmgr.ii_rc < 0 Then
	Destroy lu_dbmgr
	Return - 1
ElseIf lu_dbmgr.ii_rc = 0 Then
	If fi_play("tada.wav") = -1 Then Beep(1)
	
End If

Destroy lu_dbmgr

Return 0
end event

type mdi_1 from mdiclient within w_mdi_main
long BackColor=276856960
end type

type st_resize from statictext within w_mdi_main
event mousemove pbm_mousemove
event mousedown pbm_lbuttondown
event mouseup pbm_lbuttonup
integer x = 1938
integer width = 18
integer height = 2112
integer textsize = -12
integer weight = 400
fontpitch fontpitch = variable!
string facename = "Arial"
string pointer = "SizeWE!"
long textcolor = 33554432
long backcolor = 12632256
boolean focusrectangle = false
end type

event mousemove;Int li_chg_width

If ib_mouse_move And ii_old_mouse_x <> xpos Then
	Parent.SetRedraw(False)

	X = (tv_menu.Width + tv_menu.X) + xpos
	tv_menu.Width = X - tv_menu.X

	li_chg_width = tv_menu.X + tv_menu.Width //+ st_resize.Width //<== 이상하지만, 있으면 여백 생김..

	//By jsj
	//mdi_1.Resize(Parent.WorkSpaceWidth() - li_chg_width, &
	// Parent.WorkSpaceHeight() + Parent.WorkSpaceY())

	//	If tv_menu.Width > 1 Then
	//		mdi_1.X = X + st_resize.Width
	//	End If

	ii_old_mouse_x = xpos

	Parent.SetRedraw(True)
End If

end event

event mousedown;ib_mouse_move = True
ii_old_mouse_x = xpos

end event

event mouseup;If tv_menu.Width < 1 Then
	This.X = 1
Else
	This.X = tv_menu.Width + xpos
End If

ib_mouse_move = False

tv_menu.Width = This.X - tv_menu.X

//BY jsj
//mdi_1.X = This.X + st_resize.Width
//
end event

event constructor;This.BackColor = Parent.BackColor
end event

type tv_menu from u_tv_a_hirachy within w_mdi_main
event ue_post ( )
integer width = 1929
integer height = 2088
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 16777215
borderstyle borderstyle = styleraised!
long picturemaskcolor = 12632256
end type

event ue_post;call super::ue_post;long ll_tvi

ll_tvi = This.FindItem(RootTreeItem! , 0)
This.ExpandItem(ll_tvi)

end event

event constructor;call super::constructor;uf_init("d_menu", "00000000", FALSE)

This.PostEvent("ue_post")

end event

event doubleclicked;TreeViewItem 	ltvi_current
String 			ls_pgm_id, 		ls_pgm_name, 	ls_call_type, 	ls_call_name[4], &
					ls_pgm_type, 	ls_p_pgm_id, 	ls_p_pgm_name
Dec{0} 			lc_upd_auth
u_cust_a_msg 	lu_cust_msg
Window 			lw_temp
Int 				li_i

SetPointer(HourGlass!)

This.GetItem(handle, ltvi_current)

//messagebox("handle", string(handle))

If handle = 0 Then Return		//Not Clicked in TreeViewItem

ls_pgm_id 		= ltvi_current.data
ls_pgm_name 	= ltvi_current.label


ids_source.SetFilter( " code = '"+ ls_pgm_id + "' " )
ids_source.Filter()


//** Hard Coding For Help File **
If ls_pgm_id = '00100010' Then
	ShowHelp("hrsys.hlp", Index!)
//	ShowHelp("hrsys.hlp", Topic!)
	Return
End If
//*******************************




Choose Case String(ids_source.Object.item_type[1])
	Case "M"	//Menu
		Return
	Case "P" //Program
		//*** clicked TreeeViewItem을 이용 해당 정보 읽어오기 ***
	
		//같은 프로그램 작동 중인지를 검사
		For li_i = 1 To gi_open_win_no
			If gs_pgm_id[li_i] = ls_pgm_id Then
				f_msg_usr_err_app(504, Parent.Title, ls_pgm_name)
				Return
			End If
		Next
		
		//Window가 Max값 이상 열려있닌지 비교
		If gi_open_win_no + 1 > gi_max_win_no Then
			f_msg_usr_err_app(505, Parent.Title, "")
			Return
		End If
      
		//메뉴를 열때 다시 한번 확인
	   gi_group_auth = wfi_get_low_auth(gs_user_id, ls_pgm_id)
		//Help를 부르기 위함
	   is_pgm_id = ls_pgm_id
	
		//Clicked TreeViewItem 자신의 정보
		lc_upd_auth 		= ids_source.Object.upd_auth[1]			//프로그램의 자신의 권한
		ls_call_type 		= ids_source.Object.call_type[1]
		ls_call_name[1] 	= ids_source.Object.call_nm1[1]
		ls_call_name[2] 	= ids_source.Object.call_nm2[1]
		ls_call_name[3] 	= ids_source.Object.call_nm3[1]
		ls_call_name[4] 	= ids_source.Object.call_nm4[1]
		ls_pgm_type 		= ids_source.Object.pgm_type[1]
	
		
		//Clicked TreeViewItem의 상위 TreeViewItem 정보 
		ls_p_pgm_id = ids_source.Object.p_code[1]         //프로그램의 부모의 id
		ids_source.SetFilter( " code = '"+ ls_p_pgm_id + "' " )
		ids_source.Filter()

		ls_p_pgm_name = ids_source.Object.code_name[1] 

//		//권한 점검
//		If lc_upd_auth > gi_auth Then
//			f_msg_usr_err_app(507, Parent.Title, "")
//			Return
//		End If

		//*** 메세지 전달 객체에 자료 저장 ***
		lu_cust_msg 				= Create u_cust_a_msg
		
		lu_cust_msg.is_pgm_id 	= ls_pgm_id
		lu_cust_msg.is_grp_name = ls_p_pgm_name 
		lu_cust_msg.is_pgm_name = ls_pgm_name 
		
		lu_cust_msg.is_call_name[1] = ls_call_name[1]
		lu_cust_msg.is_call_name[2] = ls_call_name[2]
		lu_cust_msg.is_call_name[3] = ls_call_name[3]
		lu_cust_msg.is_call_name[4] = ls_call_name[4]
		lu_cust_msg.is_pgm_type 	 = ls_pgm_type

      //by jsj
		m_mdi_main.m_start.TriggerEvent(Clicked!)
		//
	
		//call_type에 따른 처리(Window Open)
		Choose Case Upper(ls_call_type)
			Case "M"		//Main
			Case "P"		//Popup
			Case "C"		//Child
			Case "R"		//Response
				If OpenWithParm(lw_temp, lu_cust_msg,  ls_call_name[1], gw_mdi_frame) <> 1 Then
					f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " +  "window is not opened")
				End If
			Case "S"		//MDI Sheet
				If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
					f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " +  "window is not opened")
					Return
				End If
				
				
		End Choose

		//pgm_type에 따른 처리(Window의 종류에 따른 처리)
		//==> 'R' : 등록, 'P' : 출력, 'I' : 조회, 'D' : 처리
		Choose Case Upper(ls_pgm_type)
			Case "D"

			Case "R"
				lw_temp.Icon = gs_ico_reg

			Case "P"
				lw_temp.Icon = gs_ico_prt

			Case "I"
				lw_temp.Icon = gs_ico_inq
		End Choose

		Destroy lu_cust_msg
End Choose


end event

event itempopulate;Long ll_i, ll_level, ll_frow, ll_ins_handle
Int li_usr_auth, li_cmp_auth
String ls_data
Boolean ib_children

String ls_type_pg

ll_level = uf_get_level(  handle ) + 1
ls_data	= uf_get_data(  handle )

ids_source.setfilter( " p_code = '"+ ls_data + "' " )
ids_source.filter()
ids_source.SetSort( " code_seq asc " ) 
ids_source.Sort()

//메뉴에 그룹을 찾음.
ll_frow = ids_source.rowcount()
For ll_i = 1 To ll_frow
	
	li_usr_auth = wfi_get_low_auth(gs_user_id, String(ids_source.Object.code[ll_i]))
	
   Choose Case Upper(String(ids_source.Object.item_type[ll_i]))
		Case "P"
			li_cmp_auth = ids_source.Object.upd_auth[ll_i]
			If li_usr_auth > li_cmp_auth or li_usr_auth = -1 Then Continue
			ib_children = False
			ll_level = 3
		Case "M"
			If li_usr_auth = -1 Then Continue
			ib_children = True
			ll_level = 2
	End Choose
   
   ls_type_pg = ids_source.Object.pgm_type[ll_i]

	
	ll_ins_handle = uf_add_item(  ids_source.object.code[ ll_i ] , &
	 ids_source.object.code_name[ ll_i ] ,  handle, ll_level, ib_children,ls_type_pg )
Next

end event

event key;call super::key;Choose Case key
	Case KeyEnter!
		This.Trigger Event Clicked(il_selected_handle)
		This.Trigger Event DoubleClicked(il_selected_handle)
	//Help 호출
	Case KeyF1!
		fs_show_help(is_pgm_id)
	Case Else
End Choose
end event

event selectionchanged;call super::selectionchanged;TreeViewItem ltvi_current

il_selected_handle = newhandle

This.GetItem(newhandle, ltvi_current)
//by jsj
//gw_mdi_frame.Title = gs_title + " : " + ltvi_current.Label
//
end event

