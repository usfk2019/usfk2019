$PBExportHeader$b5w_inq_reqdtl_paymst.srw
$PBExportComments$*[backgu-2002/09/24] 청구거래내역조회
forward
global type b5w_inq_reqdtl_paymst from w_a_inq_m_m
end type
end forward

global type b5w_inq_reqdtl_paymst from w_a_inq_m_m
integer width = 2917
integer height = 2120
end type
global b5w_inq_reqdtl_paymst b5w_inq_reqdtl_paymst

forward prototypes
public subroutine wf_create_dtl ()
end prototypes

public subroutine wf_create_dtl ();Integer	li_milseq
String	ls_bilcodnm

String	ls_dw_syntax, ls_a, ls_b, ls_c, ls_d, ls_e, ls_f, ls_s
Integer	li_i, li_x = 645, li_term = 398, li_width = 384
String	ls_modify, ls_column

dw_detail.Reset()
dw_detail.SetRedraw(False)

//DW Syntax : A
ls_a = "release 7;" &
+ "~r~n" + "datawindow(units=0 timer_interval=0 color=15793151 processing=0 HTMLDW=no print.documentname=~"~" print.orientation = 1 print.margin.left = 90 print.margin.right = 90 print.margin.top = 200 print.margin.bottom = 96 print.paper.source = 0 print.paper.size = 0 print.prompt=no print.buttons=no print.preview.buttons=no ) " &
+ "~r~n" + "header(height=172 color=~"536870912~" )" &
+ "~r~n" + "summary(height=88 color=~"536870912~" )" &
+ "~r~n" + "footer(height=0 color=~"536870912~" )" &
+ "~r~n" + "detail(height=72 color=~"536870912~" )" &
+ "~r~n" + "table(column=(type=char(8) updatewhereclause=no name=trdt dbname=~"trdt~" )" &
+ "~r~n" + " column=(type=char(8) updatewhereclause=no name=reqnum dbname=~"reqnum~" )"

//DW Syntax : B
SELECT COUNT(milseq) INTO :li_milseq FROM trprtc;
ls_b = ""
For li_i = 1 To li_milseq
	ls_b += "~r~n" + " column=(type=decimal(2) updatewhereclause=no name=amt_" + String(li_i) + " dbname=~"amt_" + String(li_i) + "~" initial=~"0~" )"
Next
ls_b += "~r~n" + " )"

//DW Syntax : C
ls_c = "~r~n" + "text(band=header alignment=~"0~" text=~"~" border=~"0~" color=~"0~" x=~"41~" y=~"36~" height=~"60~" width=~"1093~"  name=t_marknm  font.face=~"Arial~" font.height=~"-10~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )" &
	  + "~r~n" + "compute(band=header alignment=~"0~" expression=~"today()~"border=~"0~" color=~"0~" x=~"1152~" y=~"36~" height=~"60~" width=~"626~" format=~"[SHORTDATE] [TIME]~"  name=compute_1  font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )" &
	  + "~r~n" + "button(band=header text=~"Print...~"filename=~"~"action=~"15~" border=~"0~" color=~"0~" x=~"2473~" y=~"20~" height=~"80~" width=~"247~" vtextalign=~"0~" htextalign=~"0~"  name=b_1  font.face=~"Arial~" font.height=~"-10~" font.weight=~"700~"  font.family=~"2~" font.pitch=~"2~" font.charset=~"0~" background.mode=~"2~" background.color=~"67108864~" )" &
	  + "~r~n" + "text(band=header alignment=~"2~" text=~"As Of~" border=~"2~" color=~"16777215~" x=~"41~" y=~"112~" height=~"60~" width=~"288~"  name=trdt_t  font.face=~"Arial~" font.height=~"-9~" font.weight=~"700~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"2~" background.color=~"8421504~" )" &
	  + "~r~n" + "text(band=header alignment=~"2~" text=~"Invoice No~" border=~"2~" color=~"16777215~" x=~"345~" y=~"112~" height=~"60~" width=~"300~"  name=t_1  font.face=~"Arial~" font.height=~"-9~" font.weight=~"700~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"2~" background.color=~"8421504~" )" &
	  + "~r~n" + "column(band=detail id=1 alignment=~"2~" tabsequence=32766 border=~"0~" color=~"0~" x=~"41~" y=~"8~" height=~"60~" width=~"288~" format=~"@@@@-@@-@@~"  name=trdt edit.limit=0 edit.case=any edit.autoselect=yes edit.autohscroll=yes  font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )" &
	  + "~r~n" + "column(band=detail id=2 alignment=~"0~" tabsequence=32766 border=~"0~" color=~"0~" x=~"343~" y=~"8~" height=~"60~" width=~"288~" format=~"[general]~"  name=reqnum edit.limit=0 edit.case=any edit.autoselect=yes  font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )" &
	  + "~r~n" + "text(band=summary alignment=~"2~" text=~"Total~" border=~"2~" color=~"16777215~" x=~"343~" y=~"16~" height=~"60~" width=~"288~"  name=t_2  font.face=~"Arial~" font.height=~"-10~" font.weight=~"700~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"2~" background.color=~"8421504~" )" &

//DW Syntax : D
ls_d = ""
ls_s = ""
For li_i = 1 To li_milseq
	ls_d += "~r~n" + "text(band=header alignment=~"2~" text=~"Amt " + String(li_i) + "~" border=~"2~" color=~"16777215~" x=~"" + String(li_x + (li_term * (li_i - 1))) + "~" y=~"112~" height=~"56~" width=~"384~"  name=amt_" + String(li_i) + "_t font.face=~"Arial~" font.height=~"-9~" font.weight=~"700~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"2~" background.color=~"8421504~" )"
	ls_d += "~r~n" + "column(band=detail id=" + String(li_i + 2) + " alignment=~"1~" tabsequence=32766 border=~"0~" color=~"0~" x=~"" + String(li_x + (li_term * (li_i - 1))) + "~" y=~"8~" height=~"56~" width=~"384~" format=~"#,##0~"  name=amt_" + String(li_i) + " edit.limit=0 edit.case=any edit.autoselect=yes edit.autohscroll=yes  font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )"
	ls_d += "~r~n" + "compute(band=summary alignment=~"1~" expression=~"sum(amt_" + String(li_i) + " for all)~"border=~"0~" color=~"0~" x=~"" + String(li_x + (li_term * (li_i - 1))) + "~" y=~"16~" height=~"60~" width=~"384~" format=~"#,##0~"  name=amt_" + String(li_i) + "_s font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )"
	If ls_s <> "" Then ls_s += " + "
	ls_s += "if(isnull(amt_" + String(li_i) + "), 0, amt_" + String(li_i) + ")"
Next

//DW Syntax : 가로합계
ls_d += "~r~n" + "text(band=header alignment=~"2~" text=~"계~" border=~"2~" color=~"16777215~" x=~"" + String(li_x + (li_term * (li_i - 1))) + "~" y=~"112~" height=~"56~" width=~"384~"  name=cf_amt_t font.face=~"Arial~" font.height=~"-9~" font.weight=~"700~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"2~" background.color=~"8421504~" )"
ls_d += "~r~n" + "compute(band=detail alignment=~"1~" expression=~"" + ls_s + "~" border=~"0~" color=~"0~" x=~"" + String(li_x + (li_term * (li_i - 1))) + "~" y=~"8~" height=~"56~" width=~"384~" format=~"#,##0~"  name=cfs_amt font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )"
ls_d += "~r~n" + "compute(band=summary alignment=~"1~" expression=~"sum(cfs_amt for all)~" border=~"0~" color=~"0~" x=~"" + String(li_x + (li_term * (li_i - 1))) + "~" y=~"16~" height=~"60~" width=~"384~" format=~"#,##0~"  name=cft_amt font.face=~"Arial~" font.height=~"-9~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"536870912~" )"

//DW Syntax : E
ls_e = "~r~n" + "line(band=summary x1=~"0~" y1=~"4~" x2=~"" + String(li_x + (li_term * (li_i - 1)) + li_width) + "~" y2=~"4~"  name=l_1 pen.style=~"0~" pen.width=~"9~" pen.color=~"0~"  background.mode=~"2~" background.color=~"0~" )"

//DW Syntax : F
ls_f = "~r~n" + "htmltable(border=~"1~" )" &
	  + "~r~n" + "htmlgen(clientevents=~"1~" clientvalidation=~"1~" clientcomputedfields=~"1~" clientformatting=~"0~" clientscriptable=~"0~" generatejavascript=~"1~" )" + "~r~n"

ls_dw_syntax = ls_a + ls_b + ls_c + ls_d + ls_e + ls_f
dw_detail.Create(ls_dw_syntax)

//Header Setting
DECLARE cur_read_trprth CURSOR FOR  
SELECT milseq, bilcodnm
FROM   trprtc
ORDER BY milseq;

li_i = 0
OPEN cur_read_trprth;
Do While True
	FETCH cur_read_trprth
	INTO :li_milseq, :ls_bilcodnm;

	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "b5w_inq_reqdtl_paymst : cur_read_trprth")
		dw_detail.SetRedraw(True)
		Close cur_read_trprth;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If

	li_i++
	ls_modify = "amt_" + String(li_i) + "_t.Text" + "=" + "'" + ls_bilcodnm + "'"
	dw_detail.Modify(ls_modify)
Loop
Close cur_read_trprth;

dw_detail.SetRedraw(True)

end subroutine

on b5w_inq_reqdtl_paymst.create
call super::create
end on

on b5w_inq_reqdtl_paymst.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where
String ls_payid
Long   ll_rc

ls_payid = Trim(dw_cond.Object.payid[1])
If IsNull(ls_payid) Then ls_payid = ""

ls_where = ""
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "CUSTOMERM.CUSTOMERID = '" + ls_payid + "'"
End If

dw_master.is_where = ls_where
ll_rc = dw_master.Retrieve()
If ll_rc = 0 Then
	f_msg_info(1000, Title, "Master")
	Return
ElseIf ll_rc < 0 Then
	f_msg_usr_err(2100, Title, "Master : Retrieve()")
	Return
End If

end event

event open;call super::open;wf_create_dtl()

end event

type dw_cond from w_a_inq_m_m`dw_cond within b5w_inq_reqdtl_paymst
integer x = 55
integer y = 40
integer width = 1691
integer height = 144
string dataobject = "b5d_cnd_inq_reqdtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.marknm[1] = iu_cust_help.is_data2[2]
		End If
End Choose

Return 0

end event

event dw_cond::ue_init();// Help window 
This.idwo_help_col[1] = This.Object.payid

This.is_help_win[1] = "b5w_hlp_paymst"

This.is_data[1] = "CloseWithReturn"
 
end event

type p_ok from w_a_inq_m_m`p_ok within b5w_inq_reqdtl_paymst
integer x = 1902
integer y = 32
end type

type p_close from w_a_inq_m_m`p_close within b5w_inq_reqdtl_paymst
integer x = 2213
integer y = 32
end type

type gb_cond from w_a_inq_m_m`gb_cond within b5w_inq_reqdtl_paymst
integer width = 1742
integer height = 200
end type

type dw_master from w_a_inq_m_m`dw_master within b5w_inq_reqdtl_paymst
integer x = 23
integer y = 224
integer width = 2811
integer height = 572
string dataobject = "b5d_inq_reqdtl_paymst"
boolean livescroll = false
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.payid_t
uf_init(ldwo_SORT)

end event

type dw_detail from w_a_inq_m_m`dw_detail within b5w_inq_reqdtl_paymst
integer x = 23
integer y = 828
integer width = 2811
integer height = 1148
end type

event type integer dw_detail::ue_retrieve(long al_select_row);String ls_payid, ls_marknm
Int li_rc

b5u_print lu_print
lu_print = Create b5u_print

Parent.Pointer = "HourGlass!"
dw_detail.SetRedraw(False)

ls_payid  = dw_master.Object.customerid[al_select_row]
ls_marknm = dw_master.Object.customernm[al_select_row]

lu_print.is_title = Parent.Title
lu_print.is_caller = "b5w_inq_reqdtl_paymst%retrieve"
lu_print.is_data[1] = ls_payid
lu_print.is_data[2] = ls_marknm
lu_print.idw_data[1] = dw_detail

lu_print.uf_prc_db()

dw_detail.SetRedraw(True)
Parent.Pointer = "Arrow!"

li_rc = lu_print.ii_rc

Return li_rc
	
end event

event dw_detail::clicked;// Row Click시 b5w_inq_reqdtl_response를 연다.
// 인자는 청구번호
Long		ll_row
String	ls_reqnum, ls_marknm
b5s_str_response  lstr_response

If row > 0 Then
	ll_row = dw_master.GetSelectedRow(0)
	ls_marknm = dw_master.Object.customernm[ll_row]
	SelectRow(0, False)
	SelectRow(row, True)
	lstr_response.s_reqnum = Object.reqnum[row]
	lstr_response.s_marknm = ls_marknm
	OpenWithParm(b5w_inq_reqdtl_response, lstr_response)
End If

Return 0

end event

event dw_detail::buttonclicked;call super::buttonclicked;dw_detail.object.datawindow.print.orientation = 2
		



end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b5w_inq_reqdtl_paymst
integer y = 796
end type

