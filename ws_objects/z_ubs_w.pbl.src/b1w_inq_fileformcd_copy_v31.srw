$PBExportHeader$b1w_inq_fileformcd_copy_v31.srw
$PBExportComments$[jwlee] file상세정보 copy_v31
forward
global type b1w_inq_fileformcd_copy_v31 from w_base
end type
type dw_check from u_d_base within b1w_inq_fileformcd_copy_v31
end type
type dw_cond from u_d_external within b1w_inq_fileformcd_copy_v31
end type
type p_ok from u_p_ok within b1w_inq_fileformcd_copy_v31
end type
type p_close from u_p_close within b1w_inq_fileformcd_copy_v31
end type
type gb_1 from groupbox within b1w_inq_fileformcd_copy_v31
end type
end forward

global type b1w_inq_fileformcd_copy_v31 from w_base
integer width = 1591
integer height = 400
string title = "표준대역 Load"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
dw_check dw_check
dw_cond dw_cond
p_ok p_ok
p_close p_close
gb_1 gb_1
end type
global b1w_inq_fileformcd_copy_v31 b1w_inq_fileformcd_copy_v31

event ue_close();Close(This)
end event

event ue_ok();//표준 대역 조회
String  ls_fileformcd, ls_fileformcd_old, ls_pgm_id, ls_where
Long    ll_row, i, ll_row_count, ll_cnt
Integer li_result

ls_fileformcd = fs_snvl(dw_cond.object.fileformcd[1], '')

ls_fileformcd_old    = iu_cust_msg.is_data[1]
ls_pgm_id        = iu_cust_msg.is_data[2]

If ls_fileformcd = "" Then
//			f_msg_info(200, Title, "상세정보")
	F_GET_MSG(259, THIS.TITLE, '')
	
	dw_cond.SetColumn("fileformcd")
	Return
End If
	
If ls_fileformcd = ls_fileformcd_old Then 
	F_GET_MSG(284, THIS.TITLE, '')

	dw_cond.SetFocus()
	dw_cond.SetColumn("fileformcd")
	Return		
End If
		

// 지역별 대역정의 DW의 Rowcount가 있는지 알아와서 Message 처리
iu_cust_msg.idw_data[1].AcceptText()
ll_cnt = iu_cust_msg.idw_data[1].RowCount()

If ll_cnt > 0 Then
//	li_result = f_msg_ques_yesno2(3000,title,"",2)
	li_result = F_GET_QUES(315 , Title, "", "OKCancel!")
	If li_result = 2 Then
		Return
	End If
End If

ls_where = ""
If ls_fileformcd <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "fileformcd = '" + ls_fileformcd + "' "
End If

//retrieve
dw_check.is_where = ls_where
ll_row = dw_check.Retrieve()
If ll_row = 0 Then
//	f_msg_info(1000, Title, "")
	F_GET_MSG(268, THIS.TITLE, '')

ElseIf ll_row < 0 Then
//	f_msg_usr_err(2100, Title, "Retrieve()")
	F_GET_MSG(295, TITLE, 'Retrieve()')

	Return
End If

//복사한다.
dw_check.RowsCopy(1,dw_check.RowCount(), &
								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)

ll_row = iu_cust_msg.idw_data[1].RowCount()
For i = 1 To ll_row
	//보내온 fileformcd으로 setting을 다시 해야 한다.
	iu_cust_msg.idw_data[1].object.fileformcd[i] = ls_fileformcd_old
	iu_cust_msg.idw_data[1].object.pgm_id[i]     = ls_pgm_id
	iu_cust_msg.idw_data[1].object.crt_user[i]   = gs_user_id
	iu_cust_msg.idw_data[1].object.crtdt[i]      = fdt_get_dbserver_now()
Next


end event

on b1w_inq_fileformcd_copy_v31.create
int iCurrent
call super::create
this.dw_check=create dw_check
this.dw_cond=create dw_cond
this.p_ok=create p_ok
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_check
this.Control[iCurrent+2]=this.dw_cond
this.Control[iCurrent+3]=this.p_ok
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.gb_1
end on

on b1w_inq_fileformcd_copy_v31.destroy
call super::destroy
destroy(this.dw_check)
destroy(this.dw_cond)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b1w_inq_fileformcd_copy_v31
	Desc.	: 파일상세정보 copy
	Ver.	: 1.0
	Date	: 2007.08.30
	Programer : jin-won,lee
---------------------------------------------------------*/
Long   ll_row, li_rc
String ls_fileformce, ls_filter

DataWindowChild ldwc_nodeno

f_center_window(This)

ls_fileformce    = iu_cust_msg.is_data[1]

f_modify_dw_title(dw_cond)
//dw_cond.object.fileformcd[1]    = ls_fileformce 

Return 0 

end event

type dw_check from u_d_base within b1w_inq_fileformcd_copy_v31
integer x = 18
integer y = 332
integer width = 3173
integer height = 508
integer taborder = 20
string dataobject = "b1dw_reg_fileupload_mst_t3_v30"
end type

type dw_cond from u_d_external within b1w_inq_fileformcd_copy_v31
integer x = 41
integer y = 68
integer width = 1097
integer height = 120
integer taborder = 10
string dataobject = "b1dw_cnd_fileformcd_copy_v31"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type p_ok from u_p_ok within b1w_inq_fileformcd_copy_v31
integer x = 1198
integer y = 28
end type

type p_close from u_p_close within b1w_inq_fileformcd_copy_v31
integer x = 1198
integer y = 136
end type

type gb_1 from groupbox within b1w_inq_fileformcd_copy_v31
integer x = 23
integer y = 20
integer width = 1129
integer height = 192
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

