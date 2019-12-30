$PBExportHeader$p1w_reg_term_ani_popup.srw
$PBExportComments$[parkkh] ani# 해지popup
forward
global type p1w_reg_term_ani_popup from w_base
end type
type st_anino from statictext within p1w_reg_term_ani_popup
end type
type st_1 from statictext within p1w_reg_term_ani_popup
end type
type p_save from u_p_save within p1w_reg_term_ani_popup
end type
type p_close from u_p_close within p1w_reg_term_ani_popup
end type
type dw_detail from u_d_sort within p1w_reg_term_ani_popup
end type
type ln_2 from line within p1w_reg_term_ani_popup
end type
type ln_3 from line within p1w_reg_term_ani_popup
end type
end forward

global type p1w_reg_term_ani_popup from w_base
integer width = 2482
integer height = 760
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event type integer ue_save ( )
st_anino st_anino
st_1 st_1
p_save p_save
p_close p_close
dw_detail dw_detail
ln_2 ln_2
ln_3 ln_3
end type
global p1w_reg_term_ani_popup p1w_reg_term_ani_popup

type variables
String is_ani_syscod[], is_fromdt, is_anino, is_pgm_id

end variables

event ue_ok();Long ll_row 
String ls_where
//조회

ls_where = " validkey = '" + is_anino + "' AND to_char(fromdt,'yyyymmdd') = '" + is_fromdt + "'"

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_detail.object.todt[1] = Date(fdt_get_dbserver_now())

end event

event ue_close;Close(This)
end event

event type integer ue_save();Long ll_row
Integer li_rc
p1u_dbmgr1 	lu_dbmgr

ll_row  = dw_detail.RowCount()
If ll_row = 0 Then Return 0

//저장
lu_dbmgr = Create p1u_dbmgr1
lu_dbmgr.is_caller = "p1w_reg_term_ani_popup%save"    
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = is_anino
lu_dbmgr.is_data[2] = is_fromdt
lu_dbmgr.is_data[3] = is_pgm_id

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1  or li_rc = -2 Then
	Destroy lu_dbmgr
	Return -1
End If

Destroy lu_dbmgr

P_save.TriggerEvent("ue_disable")

Return 0
end event

on p1w_reg_term_ani_popup.create
int iCurrent
call super::create
this.st_anino=create st_anino
this.st_1=create st_1
this.p_save=create p_save
this.p_close=create p_close
this.dw_detail=create dw_detail
this.ln_2=create ln_2
this.ln_3=create ln_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_anino
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.dw_detail
this.Control[iCurrent+6]=this.ln_2
this.Control[iCurrent+7]=this.ln_3
end on

on p1w_reg_term_ani_popup.destroy
call super::destroy
destroy(this.st_anino)
destroy(this.st_1)
destroy(this.p_save)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
destroy(this.ln_3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: p1w_reg_term_ani_popop
	Desc	: Ani# 등록 (TERM)
	Ver	: 	1.0
	Date	: 	2003.08.22
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
long ll_i

f_center_window(p1w_reg_term_ani_popup)
is_anino = ""
is_fromdt = ""

//iu_cust_msg.is_data[1] = ls_anino	     //validkey
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = is_fromdt           //fromdt

iu_cust_msg = Message.PowerObjectParm
is_anino = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_fromdt = iu_cust_msg.is_data[3]

st_anino.Text = is_anino

If is_anino <> "" Then
	Post Event ue_ok()
End If
end event

type st_anino from statictext within p1w_reg_term_ani_popup
integer x = 357
integer y = 56
integer width = 741
integer height = 72
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_1 from statictext within p1w_reg_term_ani_popup
integer x = 73
integer y = 64
integer width = 302
integer height = 72
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "Ani # : "
alignment alignment = right!
boolean focusrectangle = false
end type

type p_save from u_p_save within p1w_reg_term_ani_popup
integer x = 1787
integer y = 524
boolean originalsize = false
end type

type p_close from u_p_close within p1w_reg_term_ani_popup
integer x = 2130
integer y = 524
boolean originalsize = false
end type

type dw_detail from u_d_sort within p1w_reg_term_ani_popup
integer x = 41
integer y = 168
integer width = 2386
integer height = 300
integer taborder = 10
string dataobject = "p1dw_reg_term_ani_popup"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

event ue_init();call super::ue_init;////Help Window
//This.idwo_help_col[1] = This.Object.pid
//This.is_help_win[1] = "p1w_hlp_pid"
//This.is_data[1] = "CloseWithReturn"
//
end event

type ln_2 from line within p1w_reg_term_ani_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

type ln_3 from line within p1w_reg_term_ani_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 361
integer beginy = 136
integer endx = 1079
integer endy = 136
end type

