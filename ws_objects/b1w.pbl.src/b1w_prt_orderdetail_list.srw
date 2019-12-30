$PBExportHeader$b1w_prt_orderdetail_list.srw
$PBExportComments$[chooys] 신청내역 상세 리스트 - Window
forward
global type b1w_prt_orderdetail_list from w_a_print
end type
type cb_1 from commandbutton within b1w_prt_orderdetail_list
end type
end forward

global type b1w_prt_orderdetail_list from w_a_print
integer width = 3383
cb_1 cb_1
end type
global b1w_prt_orderdetail_list b1w_prt_orderdetail_list

on b1w_prt_orderdetail_list.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on b1w_prt_orderdetail_list.destroy
call super::destroy
destroy(this.cb_1)
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_orderdtfrom, ls_orderdtto, ls_status
String	ls_customerid, ls_svccod

ls_orderdtfrom	= Trim(String(dw_cond.object.orderdtfrom[1],'yyyymmdd'))
ls_orderdtto	= Trim(String(dw_cond.object.orderdtto[1],'yyyymmdd'))
ls_status		= Trim(dw_cond.Object.status[1])
ls_customerid	= Trim(dw_cond.Object.customerid[1])
ls_svccod		= Trim(dw_cond.Object.svccod[1])

If( IsNull(ls_orderdtfrom) ) Then ls_orderdtfrom = ""
If( IsNull(ls_orderdtto) ) Then ls_orderdtto = ""
If( IsNull(ls_status) ) Then ls_status = ""
If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_svccod) ) Then ls_svccod = ""

If ls_orderdtfrom <> "" And ls_orderdtto <> "" Then
	If ls_orderdtfrom > ls_orderdtto Then
		f_msg_usr_err(211, Title, "신청일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("orderdtfrom")
		Return
	End If
End If


//Dynamic SQL
ls_where = ""

If( ls_orderdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(orderdt, 'YYYYMMDD') >= '"+ ls_orderdtfrom +"'"
End If

If( ls_orderdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(orderdt, 'YYYYMMDD') <= '"+ ls_orderdtto +"'"
End If

If( ls_status <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "svcorder.status = '"+ ls_status +"'"
End If

If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "customerm.customerid = '"+ ls_customerid +"'"
End If

If( ls_svccod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "svccod = '"+ ls_svccod +"'"
End If


dw_list.is_where	= ls_where

//Retrieve
ll_rows	= dw_list.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

//MessageBox( "ls_where",ls_where )
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로1, 가로0
ib_margin = False
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_orderdetail_list
integer x = 50
integer y = 36
integer width = 2496
integer height = 236
string dataobject = "b1dw_cnd_prtorderdetaillist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "customerid"
		Object.customernm[1] = ""

End Choose
end event

type p_ok from w_a_print`p_ok within b1w_prt_orderdetail_list
integer x = 2693
integer y = 48
end type

type p_close from w_a_print`p_close within b1w_prt_orderdetail_list
integer x = 2990
integer y = 48
end type

type dw_list from w_a_print`dw_list within b1w_prt_orderdetail_list
integer x = 23
integer y = 308
integer width = 3264
string dataobject = "b1dw_prt_orderdetaillist"
end type

type p_1 from w_a_print`p_1 within b1w_prt_orderdetail_list
integer x = 3003
end type

type p_2 from w_a_print`p_2 within b1w_prt_orderdetail_list
end type

type p_3 from w_a_print`p_3 within b1w_prt_orderdetail_list
integer x = 2702
end type

type p_5 from w_a_print`p_5 within b1w_prt_orderdetail_list
end type

type p_6 from w_a_print`p_6 within b1w_prt_orderdetail_list
end type

type p_7 from w_a_print`p_7 within b1w_prt_orderdetail_list
end type

type p_8 from w_a_print`p_8 within b1w_prt_orderdetail_list
end type

type p_9 from w_a_print`p_9 within b1w_prt_orderdetail_list
end type

type p_4 from w_a_print`p_4 within b1w_prt_orderdetail_list
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_orderdetail_list
end type

type p_port from w_a_print`p_port within b1w_prt_orderdetail_list
end type

type p_land from w_a_print`p_land within b1w_prt_orderdetail_list
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_orderdetail_list
integer width = 2528
integer height = 284
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_orderdetail_list
integer x = 2409
end type

type cb_1 from commandbutton within b1w_prt_orderdetail_list
boolean visible = false
integer x = 2034
integer y = 1728
integer width = 402
integer height = 112
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "save"
end type

event clicked;Int li_value, li_sel = 1
String ls_docname, ls_named, ls_dwtype
boolean lb_exist


// Save File XLS
li_value = GetFileSaveName("Select File", ls_docname, ls_named, "XLS","Excel Files(*.XLS),*.XLS")

// File Exist
lb_exist = FileExists(ls_docname)

// File Exist
If li_value = 1 And lb_exist Then
	if messagebox('확인','같은 이름의 화일이 이미 존재합니다.~r~n' + &
								'기존파일을 이 파일로 대체하시겠습니까?', Information!, OkCancel!, 2) = 2 then	return
End if								

//messagebox("li_value", string(li_value))

if li_value <> 1 then return

ls_dwtype = dw_list.Object.datawindow.Processing
if ls_dwtype <> '0' then		dw_list.object.datawindow.processing = 0

dw_list.SaveAs( ls_docname, CSV!, FALSE)
		
//// Ascii code 로 save
//if dw_list.SaveAsAscii(ls_docname, "~t", "") <> 1 then
//	messagebox('확인',ls_named + " 파일이름으로 생성되지 않습니다. ~r~n" + &
//							ls_named + " 파일로 열려있는지 확인하여 주십시오!")
//else
//	messagebox('확인', ls_named + " 파일이름으로 생성되었습니다.")
//end if
//
//dw_list.object.datawindow.Processing = integer(ls_dwtype)
//	
//									 
end event

