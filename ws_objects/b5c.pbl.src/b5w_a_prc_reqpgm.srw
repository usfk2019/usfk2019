$PBExportHeader$b5w_a_prc_reqpgm.srw
$PBExportComments$[hhm] 청구Process Ancester( Inherit from w_a_prc)
forward
global type b5w_a_prc_reqpgm from w_a_prc
end type
end forward

global type b5w_a_prc_reqpgm from w_a_prc
end type
global b5w_a_prc_reqpgm b5w_a_prc_reqpgm

type variables
protected privatewrite string is_cur_fr,is_cur_to,is_next_fr,is_next_to
protected privatewrite Integer ii_input_error
end variables

forward prototypes
public function string wfs_p_pgm_name (string as_pgm_id)
public function boolean wfb_check_pgm (string as_chargedt, string as_pgm_id)
end prototypes

public function string wfs_p_pgm_name (string as_pgm_id);string ls_pgm_id ,ls_pgm_nm
ls_pgm_id = as_pgm_id

Select pgm_nm
Into   :ls_pgm_nm 
From   syspgm1t
Where  pgm_id = (Select p_pgm_id From syspgm1t Where pgm_id = :ls_pgm_id);
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err("그룹프로그램명가져오기(wfs_p_pgm_name)", "")
	Return  ""
ElseIf SQLCA.SQLCode <> 0 Then
	f_msg_usr_err(1100,"그룹프로그램명가져오기(wfs_p_pgm_name)", "")
	Return ""
End If

Return ls_pgm_nm
end function

public function boolean wfb_check_pgm (string as_chargedt, string as_pgm_id);string ls_pgm_id,ls_chargedt,ls_close_yn,ls_pgm_id_arg
Boolean lb_close
int li_cnt
ls_chargedt = as_chargedt
ls_pgm_id_arg = as_pgm_id

ls_close_yn = ''
ls_pgm_id = ''

Select pgm_id
Into  :ls_pgm_id
From   reqpgm
Where seq = ( Select MIN(seq) 
              From   reqpgm
              Where  chargedt = :ls_chargedt
				         And close_yn = 'N')
      And chargedt = :ls_chargedt							
		And close_yn = 'N';// and pgm_id = :ls_pgm_id;
		
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err("작업 완료 여부 Check(wfb_check_pgm)", "")
ElseIf SQLCA.SQLCode <> 0 Then
	f_msg_usr_err(1100,"작업완료여부check(wfb_check_pgm)", "")
End If

If ls_pgm_id = ls_pgm_id_arg Then //ls_close_yn = 'N'  Then
	Select count(*)
   Into  :li_cnt
   From   reqpgm
   Where  seq < ( Select seq
                 From   reqpgm
                 Where  chargedt = :ls_chargedt
				      And pgm_id = :ls_pgm_id)
   And chargedt = :ls_chargedt							
	AND  cancel_yn = 'Y' ;// cancel된것이 있는지 확인;
   If li_cnt = 0 Then
	
	   Return True
	End If
End If		

f_msg_usr_err(3300,"작업완료여부check(wfb_check_pgm)", "")
Return False


end function

on b5w_a_prc_reqpgm.create
call super::create
end on

on b5w_a_prc_reqpgm.destroy
call super::destroy
end on

event open;call super::open;string ls_p_pgm_name
ls_p_pgm_name = wfs_p_pgm_name(iu_cust_msg.is_pgm_id)
If ls_p_pgm_name = '' Then
	Return
End If

If ls_p_pgm_name <> iu_cust_msg.is_grp_name Then   
   dw_input.object.chargedt[1] = iu_cust_msg.is_data[1]
	dw_input.object.chargedt.protect = 1	
End If
end event

event type integer ue_input();
Int li_rc
String ls_chargedt,ls_sysdate,ls_date

ii_input_error = -1

//***** 입력부분 코딩 *****
//처리를 위한 정보를 임시변수에 저장
dw_input.AcceptText()

ls_chargedt = Trim(String(dw_input.Object.chargedt[1]))
If IsNull(ls_chargedt) Then ls_chargedt = ""

//***** 입력된 변수의 Validation Check *****
If ls_chargedt = "" Then
	f_msg_usr_err(200, This.title, '청구주기')
	dw_input.SetFocus()
	dw_input.SetColumn("chargedt")
	Return ii_input_error
End If

Boolean lb_check
lb_check = wfb_check_pgm(dw_input.object.chargedt[1],iu_cust_msg.is_pgm_id)
If lb_check = False Then
	Return ii_input_error 
End IF

ls_Date = b5fs_reqterm(dw_input.object.chargedt[1],"") 
is_cur_fr = MidA(ls_date,1,8) //현월청구시작일
is_cur_to = MidA(ls_date,9,8) //현월청구마지막일 
is_next_fr = MidA(ls_date,17,8) //익월청구시작일
is_next_to = MidA(ls_date,25,8) //익월청구마지막일 
ii_input_error = 0
Return ii_input_error

end event

type p_ok from w_a_prc`p_ok within b5w_a_prc_reqpgm
end type

type dw_input from w_a_prc`dw_input within b5w_a_prc_reqpgm
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b5w_a_prc_reqpgm
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_a_prc_reqpgm
end type

type ln_up from w_a_prc`ln_up within b5w_a_prc_reqpgm
end type

type ln_down from w_a_prc`ln_down within b5w_a_prc_reqpgm
end type

type p_close from w_a_prc`p_close within b5w_a_prc_reqpgm
end type

