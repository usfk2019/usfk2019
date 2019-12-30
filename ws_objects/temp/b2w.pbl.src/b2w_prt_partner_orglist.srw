$PBExportHeader$b2w_prt_partner_orglist.srw
$PBExportComments$[cuesee] 대리점 조직도
forward
global type b2w_prt_partner_orglist from w_a_print
end type
end forward

global type b2w_prt_partner_orglist from w_a_print
end type
global b2w_prt_partner_orglist b2w_prt_partner_orglist

on b2w_prt_partner_orglist.create
call super::create
end on

on b2w_prt_partner_orglist.destroy
call super::destroy
end on

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b2w_prt_partner_orglist
	Desc	: 	대리점 영업 조직도
	Ver.	: 	1.0
	Date	: 	2002.10.29
	Programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
end event

event ue_ok;call super::ue_ok;//조회
String ls_levelcod, ls_where, ls_title, ls_sql
Long ll_cnt, i, ll_row

ls_levelcod = Trim(dw_cond.object.levelcod[1])
If IsNull(ls_levelcod) Then ls_levelcod = ""

ls_where = ""

If ls_levelcod = "" Then
	Select count(*) into :ll_cnt From syscod2t 
	where grcode = 'A100' and use_yn = 'Y' and code <> '000'
	order by code;
Else
	Select count(*) into :ll_cnt From syscod2t 
	where grcode = 'A100' and use_yn = 'Y' and code <= :ls_levelcod and code <> '000'
	order by code;
End If

If ls_levelcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "levelcod <= '" + ls_levelcod + "' "
End If


dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If


////레포트의 Title 값을 가져오기 위함.
//Declare title Dynamic Cursor For SQLSA;
//	ls_sql = "select codenm  from syscod2t " + &
//				"where grcode = 'A100' and use_yn = 'Y' and code <> '000' "
//				
//	If ls_levelcod <> "" Then
//     ls_sql += "and levelcod <= '" + ls_levelcod + "' " + &
//	  				"order by code"
//	Else
//	  ls_sql += "order by code"
//	End If
//Prepare SQLSA From  :ls_sql;
//
//
//i = 1  //초기화
//Open Dynamic title;
//Do While(True)
//	Fetch title
//	Into :ls_title;
//	If SQLCA.SQLCode < 0 Then				//Error
//		Close title;
//		Return
//	End If
//
//		Choose Case i
//			Case 1
//				dw_list.object.a_1_t.Text = ls_title
//				
//			Case 2
//				dw_list.object.a_2_t.Text = ls_title
//	
//			Case 3
//				dw_list.object.a_3_t.Text = ls_title
//			
//			Case 4
//				dw_list.object.a_4_t.Text = ls_title
//			
//			Case 5
//				dw_list.object.a_5_t.Text = ls_title
//			
//			Case 6
//				dw_list.object.a_6_t.Text = ls_title
//				
//			Case 7
//				dw_list.object.a_7_t.Text = ls_title
//			
//			Case 8
//				dw_list.object.a_8_t.Text = ls_title
//				
//			Case 9
//				dw_list.object.a_9_t.Text = ls_title
//				
//			Case 10
//				dw_list.object.a_10_t.Text = ls_title
//				exit
//		End Choose
//	  //총갯수와 같지 않으면
//     If i <>  ll_cnt Then i++
//Loop
////close cursor
//Close title;	
//

			
			
		
	
	
	
	



	  
	
	

end event

type dw_cond from w_a_print`dw_cond within b2w_prt_partner_orglist
integer width = 1417
integer height = 148
string dataobject = "b2dw_cnd_prt_partner_orglist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_partner_orglist
integer x = 1733
integer y = 40
end type

type p_close from w_a_print`p_close within b2w_prt_partner_orglist
integer x = 2034
integer y = 40
end type

type dw_list from w_a_print`dw_list within b2w_prt_partner_orglist
integer y = 240
integer height = 1380
string dataobject = "b2dw_prt_partner_orglist"
end type

type p_1 from w_a_print`p_1 within b2w_prt_partner_orglist
end type

type p_2 from w_a_print`p_2 within b2w_prt_partner_orglist
end type

type p_3 from w_a_print`p_3 within b2w_prt_partner_orglist
end type

type p_5 from w_a_print`p_5 within b2w_prt_partner_orglist
end type

type p_6 from w_a_print`p_6 within b2w_prt_partner_orglist
end type

type p_7 from w_a_print`p_7 within b2w_prt_partner_orglist
end type

type p_8 from w_a_print`p_8 within b2w_prt_partner_orglist
end type

type p_9 from w_a_print`p_9 within b2w_prt_partner_orglist
end type

type p_4 from w_a_print`p_4 within b2w_prt_partner_orglist
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_partner_orglist
end type

type p_port from w_a_print`p_port within b2w_prt_partner_orglist
end type

type p_land from w_a_print`p_land within b2w_prt_partner_orglist
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_partner_orglist
integer width = 1577
integer height = 224
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_partner_orglist
end type

