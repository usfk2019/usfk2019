$PBExportHeader$w_find_admst.srw
$PBExportComments$[1hera] 장비마스터조회
forward
global type w_find_admst from w_a_hlp
end type
end forward

global type w_find_admst from w_a_hlp
integer width = 1294
integer height = 1364
string title = "fild"
end type
global w_find_admst w_find_admst

type variables
Long il_data[]
end variables

event ue_find();call super::ue_find;String ls_where
String ls_modelno, ls_temp, ls_ref_desc, ls_status
Long ll_row

dw_cond.AcceptText()

ls_where = ""
ls_modelno = Trim(dw_cond.Object.modelno[1])
If IsNull(ls_modelno) Then ls_modelno = ""

If ls_modelno = ""  Then
	f_msg_usr_err(200, This.Title, "관련 모델없음.")
	Return
End If

If ls_modelno <> ""Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "modelno = '" + ls_modelno + "'"
End If

//단품여부
ls_temp = 'Y'
If ls_temp <> ""Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "ADTYPE = '" + ls_temp + "'"
End If
//재고 상태 
ls_ref_desc = ""
ls_status = fs_get_control("E1", "A102", ls_ref_desc)
If ls_status <> ""Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "STATUS = '" + ls_status + "'"
End If

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row <= 0 Then
	f_msg_usr_err(1000, Title, "상품의 재고가 없습니다. 확인 바랍니다.")
	Return
End If


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.is_data[1] = Trim(dw_hlp.Object.adseq[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.modelno[al_selrow])
iu_cust_help.il_data[1] = dw_hlp.Object.sale_amt[al_selrow]
iu_cust_help.ib_data[1] = True

end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
//Close(This)
end event

event open;call super::open;/*--------------------------------------------------------------------
	Name	: 	find_admst
	Desc.	:	단품장비 조회
	Ver.	: 	1.0
	Date.	: 	2006.4.13
	Programer : 조경복 [1hera]
----------------------------------------------------------------------*/
This.Title = "단품판매장비"
dw_cond.Object.modelno[1] =  iu_cust_help.is_data[1]
dw_cond.Object.modelnm[1] =  iu_cust_help.is_data[2]

Post event ue_find()


end event

on w_find_admst.create
call super::create
end on

on w_find_admst.destroy
call super::destroy
end on

type p_1 from w_a_hlp`p_1 within w_find_admst
integer x = 960
integer y = 8
boolean originalsize = false
end type

type dw_cond from w_a_hlp`dw_cond within w_find_admst
integer x = 41
integer y = 64
integer width = 846
integer height = 212
integer taborder = 0
string dataobject = "d_cnd_find_admst"
end type

type p_ok from w_a_hlp`p_ok within w_find_admst
integer x = 960
integer y = 108
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within w_find_admst
integer x = 960
integer y = 208
end type

type gb_cond from w_a_hlp`gb_cond within w_find_admst
integer x = 23
integer y = 12
integer width = 873
integer height = 296
integer taborder = 0
end type

type dw_hlp from w_a_hlp`dw_hlp within w_find_admst
integer x = 0
integer y = 348
integer width = 1230
integer height = 908
string dataobject = "d_find_admst"
end type

event dw_hlp::constructor;call super::constructor;//DWObject ldwo_sort
//
//ldwo_sort = This.Object.code_t
//uf_init(ldwo_sort)
end event

