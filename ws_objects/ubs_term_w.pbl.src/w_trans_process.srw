$PBExportHeader$w_trans_process.srw
$PBExportComments$해지고객이관처리
forward
global type w_trans_process from w_a_reg_m_m
end type
end forward

global type w_trans_process from w_a_reg_m_m
integer width = 4389
integer height = 2272
string title = "고객추출"
end type
global w_trans_process w_trans_process

type variables
TRANSACTION SQLCA_TERM

String is_operator, is_operatornm, is_partner
end variables

forward prototypes
public function integer wf_authority_check ()
end prototypes

public function integer wf_authority_check ();integer li_cnt

Select count(*) into :li_cnt
from Termcust.Syscod2t
where grcode = 'TERMUSER'
   and code = :gs_user_id;
	
if li_cnt = 0 then
	messagebox("확인","조회/처리 권한이 없습니다. 관리자에게 문의하세요")
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	return -1
end if
	
return 0
end function

on w_trans_process.create
call super::create
end on

on w_trans_process.destroy
call super::destroy
end on

event open;call super::open;
//TRANSACTION SQLCA_TERM
SQLCA_TERM = CREATE TRANSACTION 
SQLCA_TERM.DBMS  = "O84 ORACLE 8.0.4"
SQLCA_TERM.SERVERNAME =SQLCA.ServerName
SQLCA_TERM.LogId = "termcust"
SQLCA_TERM.LOGPASS = "termcust123"
SQLCA_TERM.AUTOCOMMIT = FALSE
CONNECT USING SQLCA_TERM;

IF SQLCA_TERM.SQLCODE < 0 THEN
	DISCONNECT USING SQLCA_TERM;
	DESTROY SQLCA_TERM;
	MESSAGEBOX("SQLCA_TERM CONNECT ERROR", "연결에 실패하였습니다. 관리자에게 문의하시기 바랍니다")
	RETURN
END IF

dw_cond.SetFocus()
dw_cond.SetColumn("work_type")
end event

event ue_ok;call super::ue_ok;string  ls_work_type, ls_status, ls_date, ls_operator
date    ld_date
long    ll_rows
int     li_cnt, li_fcnt, li_tcnt, li_ret

dw_master.settransobject(SQLCA_TERM)
dw_detail.settransobject(SQLCA_TERM)

dw_cond.accepttext()
dw_master.accepttext()

ld_date     = dw_cond.object.target_month[1]

SELECT  TO_CHAR(:ld_date, 'YYYYMM')
INTO    :ls_date
FROM    DUAL;

ls_work_type = fs_snvl(dw_cond.object.work_type[1], "")
ls_status    = fs_snvl(dw_cond.object.status[1], "")
ls_operator  = fs_snvl(dw_cond.object.operator[1], "")


//권한체크
li_ret = wf_authority_check()
if li_ret < 0 then return
	

if ls_work_type = "" then
	f_msg_usr_err(9000, Title, "작업구분을 입력하여 주십시오.")
	return
end if

if ls_status = "" then
	f_msg_usr_err(9000, Title, "작업상태를 입력하여 주십시오.")
	return
end if

//Retrieve
ll_rows = dw_master.retrieve(ls_work_type, ls_status, ls_date)


if ls_status = '200' then //처리완료
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
else
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
end if
end event

event ue_save;string ls_errmsg,  ls_work_gubun, ls_status
date ld_target_to,ld_target_fr, ld_workdt_fr, ld_workdt_to
long ll_return, ll_workno, ll_row, ll_ref_workno, li_Ret

ll_row = dw_master.getrow()

ll_workno      = dw_master.object.workno[ll_row]
ll_ref_workno = dw_master.object.ref_workno[ll_row]
ls_work_gubun  = dw_master.object.work_gubun[ll_row]
ld_target_fr   = date(dw_master.object.target_from[ll_row] )
ld_target_to   = date(dw_master.object.target_to[ll_row] )
ld_workdt_fr   = date(dw_master.object.workdt_from[ll_row] )
ld_workdt_to   = date(dw_master.object.workdt_to[ll_row] )
ls_status      = dw_master.object.status[ll_row] 

ls_errmsg = space(256)

if ll_ref_workno > 0 or ls_status = '200'  then
	messagebox("확인", "이미 처리된 추출건(처리번호 : " +string(ll_ref_workno)+ ") 이므로 재처리 할 수 없습니다.")
	return -1
end if


//Procedure call
IF ls_work_gubun = '100' THEN
		li_Ret = messagebox("확인", "해지자이관 작업을 처리하시겠습니까?", exclamation!, yesno!, 2)
		if li_Ret = 1 then
				SQLCA.PRC_CUST_TRANSFER(ll_workno, ls_work_gubun, ls_status, ld_target_fr, ld_target_to, ld_workdt_fr, ld_workdt_to , gs_user_id,  ll_return, ls_errmsg)
				 If SQLCA.SQLCode < 0 Then        //For Programer
					  MessageBox(Title+'~r~n'+"1 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
						 RETURN  -1
					  
				 ElseIf ll_return < 0 Then    //For User
					  MessageBox(Title, "1 " + ls_errmsg)
					  RETURN  -1
					  
				 End If
		end if
ELSE
	
		li_Ret = messagebox("확인", " 보유기간만료 고객에 대한 삭제작업을 처리하시겠습니까?", exclamation!, yesno!, 2)
		if li_Ret = 1 then
				SQLCA.PRC_CUST_PROCESS(ll_workno, ls_work_gubun, ls_status, ld_target_fr, ld_target_to,  ld_workdt_fr, ld_workdt_to, gs_user_id,  ll_return, ls_errmsg)
				 If SQLCA.SQLCode < 0 Then        //For Programer
					  MessageBox(Title+'~r~n'+"1 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
						 RETURN  -1
					  
				 ElseIf ll_return < 0 Then    //For User
					  MessageBox(Title, "1 " + ls_errmsg)
					  RETURN  -1
					  
				 End If
		end if
		
END IF

messagebox('성공','처리가 완료 되었습니다!!!')
dw_cond.object.status[1] = '200' //처리건을 보여주기 위해서


Trigger Event ue_ok()
Return 0

end event

event ue_reset;call super::ue_reset;dw_cond.trigger event ue_init()


return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within w_trans_process
integer y = 64
integer width = 3145
integer height = 212
string dataobject = "d_cnd_trans_process"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String 	ls_operator, ls_empnm, ls_partner

Choose Case dwo.name

	case 'operator'
		
		SELECT EMPNM, EMP_GROUP INTO :ls_empnm, :ls_partner
		FROM   SAMS.SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm
		
		is_operator   = data
		is_operatornm = ls_empnm
		//is_partner    = ls_partner

End Choose

end event

event dw_cond::ue_init;call super::ue_init;string ls_date
int    li_cnt

this.Object.target_month[1] = Date(fdt_get_dbserver_now())

f_dddw_list2(this, 'work_type', 'TERM100')
f_dddw_list2(this, 'status', 'TERM101')

dw_cond.object.operator[1] = gs_user_id

trigger event itemchanged(1, this.object.operator, gs_user_id)



end event

type p_ok from w_a_reg_m_m`p_ok within w_trans_process
integer x = 3415
end type

type p_close from w_a_reg_m_m`p_close within w_trans_process
integer x = 3721
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_trans_process
integer width = 3186
end type

type dw_master from w_a_reg_m_m`dw_master within w_trans_process
integer y = 328
integer width = 4151
integer height = 728
string dataobject = "d_inq_trans_process"
end type

event dw_master::rowfocuschanged;call super::rowfocuschanged;long   ll_workno
string ls_date, ls_status, ls_table_nm, ls_dw_gb

If currentrow <= 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
	
	dw_detail.Reset()
	ll_workno     = this.object.workno[currentrow]
	ls_status     = dw_cond.object.status[1]	
	
	if ls_status = '100' then //추출상태일경우
	
		dw_detail.DataObject = 'd_reg_trans_process'
		dw_detail.SetTransObject(SQLCA_TERM)

		dw_detail.retrieve(ll_workno)
	else 
		//각각의 테이블에 맞게 DW 생성 및 조회
		ls_table_nm = fs_snvl(dw_master.object.table_nm[currentrow], "")
		
		if ls_table_nm = "" then
			messagebox('확인', '대상테이블 데이터가 존재하지 않아 작업결과를 볼수 없습니다.!')
			return -1
		end if
		
		SELECT  REF_CODENM1
		INTO    :ls_dw_gb
		FROM    TERMCUST.SYSCOD2T
		WHERE   GRCODE = 'TERM200'
		AND     CODENM = :ls_table_nm;
		
		dw_detail.DataObject = 'd_reg_trans_process_' + ls_dw_gb
		dw_detail.SetTransObject(SQLCA_TERM)

		dw_detail.retrieve(ll_workno)
		
	end if
	
end if
end event

event dw_master::clicked;/*sort  에러처리 잡아야함*/
end event

type dw_detail from w_a_reg_m_m`dw_detail within w_trans_process
integer y = 1112
integer width = 4165
integer height = 896
string dataobject = "d_reg_trans_process"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)

end event

type p_insert from w_a_reg_m_m`p_insert within w_trans_process
boolean visible = false
integer x = 50
integer y = 2032
end type

type p_delete from w_a_reg_m_m`p_delete within w_trans_process
boolean visible = false
integer x = 343
integer y = 2032
end type

type p_save from w_a_reg_m_m`p_save within w_trans_process
integer x = 635
integer y = 2032
boolean enabled = true
end type

type p_reset from w_a_reg_m_m`p_reset within w_trans_process
integer x = 928
integer y = 2032
boolean enabled = true
end type

event p_reset::clicked;call super::clicked;dw_cond.trigger event ue_init()
end event

type st_horizontal from w_a_reg_m_m`st_horizontal within w_trans_process
integer y = 1068
end type

