$PBExportHeader$b8w_prt_partner_adstock.srw
$PBExportComments$[parkkh] 대리점별재고현황
forward
global type b8w_prt_partner_adstock from w_a_print
end type
end forward

global type b8w_prt_partner_adstock from w_a_print
integer width = 4416
end type
global b8w_prt_partner_adstock b8w_prt_partner_adstock

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

on b8w_prt_partner_adstock.create
call super::create
end on

on b8w_prt_partner_adstock.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False

end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_partner, ls_levelcod
Long ll_row
boolean lb_check

ls_levelcod = Trim(dw_cond.object.levelcod[1])
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_levelcod) Then ls_levelcod = ""
If IsNull(ls_partner) Then ls_partner = ""

ls_where = ""
If ls_levelcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "pa.levelcod = '" + ls_levelcod + "' " 
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "ad.mv_partner = '" + ls_partner + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b8w_prt_partner_adstock
	Desc.	: 대리점별재고현황
	Date	: 2002.10.30
	Ver.	: 1.0
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/

end event

event ue_saveas;STRING	ls_partner,			ls_partnernm,			ls_sysdate
datawindow	ldw

ls_partner = dw_cond.Object.partner[1]

SELECT PARTNERNM
INTO   :ls_partnernm
FROM   PARTNERMST
WHERE  PARTNER = :ls_partner;

SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
INTO   :ls_sysdate
FROM   DUAL;

ldw = dw_list

f_excel_new(ldw, ls_partnernm+"_"+ls_sysdate)
end event

type dw_cond from w_a_print`dw_cond within b8w_prt_partner_adstock
integer y = 80
integer width = 2222
integer height = 96
string dataobject = "b8dw_cnd_prt_partner_adstock"
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

type p_ok from w_a_print`p_ok within b8w_prt_partner_adstock
integer x = 2441
end type

type p_close from w_a_print`p_close within b8w_prt_partner_adstock
integer x = 2757
end type

type dw_list from w_a_print`dw_list within b8w_prt_partner_adstock
integer x = 23
integer y = 256
integer width = 4315
integer height = 1348
string dataobject = "b8dw_prt_partner_adstock"
end type

type p_1 from w_a_print`p_1 within b8w_prt_partner_adstock
end type

type p_2 from w_a_print`p_2 within b8w_prt_partner_adstock
end type

type p_3 from w_a_print`p_3 within b8w_prt_partner_adstock
end type

type p_5 from w_a_print`p_5 within b8w_prt_partner_adstock
end type

type p_6 from w_a_print`p_6 within b8w_prt_partner_adstock
end type

type p_7 from w_a_print`p_7 within b8w_prt_partner_adstock
end type

type p_8 from w_a_print`p_8 within b8w_prt_partner_adstock
end type

type p_9 from w_a_print`p_9 within b8w_prt_partner_adstock
end type

type p_4 from w_a_print`p_4 within b8w_prt_partner_adstock
end type

type gb_1 from w_a_print`gb_1 within b8w_prt_partner_adstock
end type

type p_port from w_a_print`p_port within b8w_prt_partner_adstock
end type

type p_land from w_a_print`p_land within b8w_prt_partner_adstock
end type

type gb_cond from w_a_print`gb_cond within b8w_prt_partner_adstock
integer width = 2286
integer height = 232
end type

type p_saveas from w_a_print`p_saveas within b8w_prt_partner_adstock
end type

