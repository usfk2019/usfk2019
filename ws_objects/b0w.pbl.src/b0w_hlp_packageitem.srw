$PBExportHeader$b0w_hlp_packageitem.srw
$PBExportComments$[chooys] Package Item 구성 - 품목ID Help Window
forward
global type b0w_hlp_packageitem from w_a_hlp
end type
end forward

global type b0w_hlp_packageitem from w_a_hlp
integer width = 3717
end type
global b0w_hlp_packageitem b0w_hlp_packageitem

on b0w_hlp_packageitem.create
call super::create
end on

on b0w_hlp_packageitem.destroy
call super::destroy
end on

event open;call super::open;This.Title = "품목ID Help Window"
end event

event ue_close;call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return;call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True

iu_cust_help.is_data2[1] = Trim(dw_hlp.Object.itemcod[al_selrow])
iu_cust_help.is_data2[2] = Trim(dw_hlp.Object.itemnm[al_selrow])
end event

event ue_find;call super::ue_find;Long		ll_rows
String	ls_where
String	ls_itemnm, ls_svccod, ls_categoryc, ls_categoryb, ls_categorya

//검색조건 입력값
ls_itemnm = Trim(dw_cond.Object.itemnm[1])
If IsNull(ls_itemnm) Then ls_itemnm = ""

ls_svccod = Trim(dw_cond.Object.svccod[1])
If IsNull(ls_svccod) Then ls_svccod = ""

ls_categoryc = Trim(dw_cond.Object.categoryc[1])
If IsNull(ls_categoryc) Then ls_categoryc = ""

ls_categoryb = Trim(dw_cond.Object.categoryb[1])
If IsNull(ls_categoryb) Then ls_categoryb = ""

ls_categorya = Trim(dw_cond.Object.categorya[1])
If IsNull(ls_categorya) Then ls_categorya = ""


//Dynamic SQL
ls_where = ""

If ls_itemnm <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " itemnm like '%" + ls_itemnm + "%'"
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "svccod = '" + ls_svccod + "'"
End If

If ls_categoryc <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "categoryb.categoryc = '" + ls_categoryc + "'"
End If

If ls_categoryb <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "categorya.categoryb = '" + ls_categoryb + "'"
End If


If ls_categorya <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "itemmst.categorya = '" + ls_categorya + "'"
End If


dw_hlp.is_where = ls_where
ll_rows = dw_hlp.Retrieve()

If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

type p_1 from w_a_hlp`p_1 within b0w_hlp_packageitem
integer x = 2757
integer y = 84
boolean originalsize = false
end type

type dw_cond from w_a_hlp`dw_cond within b0w_hlp_packageitem
integer x = 37
integer y = 44
integer width = 2578
integer height = 252
string dataobject = "b0dw_cnd_hlp_itemcod"
end type

type p_ok from w_a_hlp`p_ok within b0w_hlp_packageitem
integer x = 3063
integer y = 84
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b0w_hlp_packageitem
integer x = 3369
integer y = 84
end type

type gb_cond from w_a_hlp`gb_cond within b0w_hlp_packageitem
integer x = 23
integer width = 2633
integer height = 328
end type

type dw_hlp from w_a_hlp`dw_hlp within b0w_hlp_packageitem
integer x = 23
integer y = 340
integer width = 3305
integer height = 1448
string dataobject = "b0dw_inq_hlp_itemmst"
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort

ldwo_sort = This.Object.itemcod_t

uf_init(ldwo_sort)
end event

