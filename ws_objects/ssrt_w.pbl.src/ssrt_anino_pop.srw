$PBExportHeader$ssrt_anino_pop.srw
$PBExportComments$애니번호조회
forward
global type ssrt_anino_pop from w_a_hlp
end type
end forward

global type ssrt_anino_pop from w_a_hlp
integer width = 1705
integer height = 1364
string title = "fild"
end type
global ssrt_anino_pop ssrt_anino_pop

type variables
Long il_data[]
end variables

event ue_find();call super::ue_find;String ls_where
String ls_anino
Long ll_row

dw_cond.AcceptText()

ls_where = ""
ls_anino = Trim(dw_cond.Object.anino[1])
If IsNull(ls_anino) Then ls_anino = ""

If ls_anino = ""  Then
	f_msg_usr_err(200, This.Title, "Ani No.")
	Return
End If

ll_row = dw_hlp.Retrieve(ls_anino)
If ll_row <= 0 Then
	f_msg_usr_err(9000, Title, "Ani No.를 찾을 수 없음. 확인 바랍니다.")
	Return
End If


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.is_data[1] = Trim(dw_hlp.Object.contno[al_selrow])
iu_cust_help.il_data[1] = dw_hlp.Object.left_val[al_selrow]
iu_cust_help.ib_data[1] = True

end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
//Close(This)
end event

event open;call super::open;/*--------------------------------------------------------------------
	Name	: 	find_ani No
	Desc.	:	Ani No 조회
	Ver.	: 	1.0
	Date.	: 	2006.11.9
	Programer : 조경복 [1hera]
----------------------------------------------------------------------*/
This.Title = "Search -  Ani No."

//Post event ue_find()


end event

on ssrt_anino_pop.create
call super::create
end on

on ssrt_anino_pop.destroy
call super::destroy
end on

type p_1 from w_a_hlp`p_1 within ssrt_anino_pop
integer x = 1019
integer y = 8
boolean originalsize = false
end type

type dw_cond from w_a_hlp`dw_cond within ssrt_anino_pop
integer x = 41
integer y = 64
integer width = 873
integer height = 156
integer taborder = 0
string dataobject = "ssrt_cnd_anino_pop"
end type

type p_ok from w_a_hlp`p_ok within ssrt_anino_pop
integer x = 1019
integer y = 108
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within ssrt_anino_pop
integer x = 1019
integer y = 208
end type

type gb_cond from w_a_hlp`gb_cond within ssrt_anino_pop
integer x = 23
integer y = 12
integer width = 905
integer height = 248
integer taborder = 0
end type

type dw_hlp from w_a_hlp`dw_hlp within ssrt_anino_pop
integer x = 0
integer y = 324
integer width = 1582
integer height = 908
string dataobject = "ssrt_anino_pop"
end type

event dw_hlp::constructor;call super::constructor;//DWObject ldwo_sort
//
//ldwo_sort = This.Object.code_t
//uf_init(ldwo_sort)
end event

