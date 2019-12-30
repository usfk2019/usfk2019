$PBExportHeader$b8w_prt_admove_request.srw
$PBExportComments$[parkkh] 장비이동쵸엉리스트
forward
global type b8w_prt_admove_request from w_a_print
end type
end forward

global type b8w_prt_admove_request from w_a_print
integer width = 3982
end type
global b8w_prt_admove_request b8w_prt_admove_request

forward prototypes
public function integer wfi_get_partner (string as_partner)
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
 Into :ls_partnernm
 From partnermst
Where partner = :as_partner
  and partner_type ='0';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

on b8w_prt_admove_request.create
call super::create
end on

on b8w_prt_admove_request.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False

end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_requestdt, ls_trc_yn
date ld_requestdt
Long ll_row
boolean lb_check

ld_requestdt = dw_cond.object.requestdt[1]
ls_requestdt = String(ld_requestdt, 'yyyymmdd')
ls_trc_yn = dw_cond.object.trc_yn[1]

If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_trc_yn) Then ls_trc_yn = ""

//ranger가 확정이 되면
If ls_requestdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(requestdt,'YYYYMMDD') <='" + ls_requestdt + "' " 
End If

If ls_trc_yn <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "trc_yn = '" + ls_trc_yn + "' "
End if

If ls_requestdt <> ""  Then
	dw_list.object.requestdt_t.Text = String(ld_requestdt,'yyyy-mm-dd') + " 까지"
End If

dw_list.is_where = ls_where
ll_row = dw_list.retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "trcrieve()")
End If
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b8w_prt_admove_request
	Desc.	: 장비이동오청리스트
	Date	: 2002.11.01
	Ver.	: 1.0
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/

end event

type dw_cond from w_a_print`dw_cond within b8w_prt_admove_request
integer x = 78
integer y = 84
integer width = 1947
integer height = 92
string dataobject = "b8dw_cnd_prt_admove_request"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_partner
Long li_exist
String ls_filter

Choose Case dwo.name
	Case "levelcod"
		//LEVELCOD가 바뀜에 따라서 대리점 바뀐다...
		This.object.partner[row] = ''		//DDDW 구함				
		li_exist = this.GetChild("partner", ldc_partner)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 대리점")
	
		ls_filter = "levelcod = '" + data  + "'" 				
		ldc_partner.SetTransObject(SQLCA)
		li_exist =ldc_partner.Retrieve()
		ldc_partner.SetFilter(ls_filter)			//Filter정함
		ldc_partner.Filter()
		
		If li_exist < 0 Then 				
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 1  		//선택 취소 focus는 그곳에
		End If  

End Choose	
end event

type p_ok from w_a_print`p_ok within b8w_prt_admove_request
integer x = 2203
integer y = 48
end type

type p_close from w_a_print`p_close within b8w_prt_admove_request
integer x = 2528
integer y = 48
end type

type dw_list from w_a_print`dw_list within b8w_prt_admove_request
integer x = 23
integer y = 256
integer width = 3890
integer height = 1348
string dataobject = "b8dw_prt_admove_request"
end type

type p_1 from w_a_print`p_1 within b8w_prt_admove_request
end type

type p_2 from w_a_print`p_2 within b8w_prt_admove_request
end type

type p_3 from w_a_print`p_3 within b8w_prt_admove_request
end type

type p_5 from w_a_print`p_5 within b8w_prt_admove_request
end type

type p_6 from w_a_print`p_6 within b8w_prt_admove_request
end type

type p_7 from w_a_print`p_7 within b8w_prt_admove_request
end type

type p_8 from w_a_print`p_8 within b8w_prt_admove_request
end type

type p_9 from w_a_print`p_9 within b8w_prt_admove_request
end type

type p_4 from w_a_print`p_4 within b8w_prt_admove_request
end type

type gb_1 from w_a_print`gb_1 within b8w_prt_admove_request
end type

type p_port from w_a_print`p_port within b8w_prt_admove_request
end type

type p_land from w_a_print`p_land within b8w_prt_admove_request
end type

type gb_cond from w_a_print`gb_cond within b8w_prt_admove_request
integer x = 23
integer width = 2066
integer height = 236
end type

type p_saveas from w_a_print`p_saveas within b8w_prt_admove_request
end type

