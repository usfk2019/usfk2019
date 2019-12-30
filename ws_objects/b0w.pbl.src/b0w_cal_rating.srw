$PBExportHeader$b0w_cal_rating.srw
$PBExportComments$[jsha] 요금계산기
forward
global type b0w_cal_rating from w_a_prc
end type
end forward

global type b0w_cal_rating from w_a_prc
integer width = 3790
integer height = 2504
end type
global b0w_cal_rating b0w_cal_rating

type variables
String is_msg_ratetype
String is_msg_zoncod
String is_msg_tmcod

String is_time[]
String is_f[]
String is_amt[]

boolean ib_display[]
boolean ib_mdisplay[]

long il_fsum
long il_mfsum
end variables

forward prototypes
public function decimal f_calc_range_partial (long range[], long sec[], decimal fee[], long biltime, string roundflag, integer index)
private function decimal f_calc_bilamt (long bsec, decimal bfee, long range[], ref long sec[], decimal fee[], long biltime, string roundflag)
public subroutine f_display_bilamt (long time, long unitsec, decimal unitfee, string roundflag, integer index)
public function decimal f_calc_range_full (long range[], long sec[], decimal fee[], string roundflag, integer index)
public function long f_calc_usabletime (long bsec, decimal bfee, long range[], long sec[], long fee[], long balance, string roundflag)
public function decimal f_calc_basic (long bsec, decimal bfee, long biltime, string roundflag)
end prototypes

public function decimal f_calc_range_partial (long range[], long sec[], decimal fee[], long biltime, string roundflag, integer index);Dec lc_bilamt
Int i
Long ll_sum_range, ll_biltime

ll_sum_range = 0
For i = 1 To index - 1
	ll_sum_range += range[i]
Next

ll_biltime = biltime - ll_sum_range

If roundflag = 'U' Then
	lc_bilamt = Round(0.499999 + ll_biltime/sec[index], 0) * fee[index]
ElseIf roundflag = 'D' Then
	lc_bilamt = Truncate(ll_biltime/sec[index], 0) * fee[index]
Else
	lc_bilamt = Round(ll_biltime/sec[index], 0) * fee[index]
End If

f_display_bilamt(ll_biltime, sec[index], fee[index], roundflag, index+1)

Return lc_bilamt
end function

private function decimal f_calc_bilamt (long bsec, decimal bfee, long range[], ref long sec[], decimal fee[], long biltime, string roundflag);//
Dec lc_bilamt
Int i, rindex
Long ll_sum_range_a, ll_sum_range_b, pos

// 총 시간대
For i = 1 To 5
	If range[i] = 0 OR IsNull(range[i]) Then 
		rindex = i - 1
		Exit
	End If
Next

// biltime이 속해있는 시간대를 찾는다.
ll_sum_range_a = 0
For i = 1 To rindex 
	ll_sum_range_b = ll_sum_range_a + range[i]
	If ll_sum_range_a <= biltime AND biltime < ll_sum_range_b Then
		pos = i
	End If
	ll_sum_range_a += range[i]
Next

If pos = 0 Then
	pos = rindex + 1
End If

// bilamt 계산
If rindex = 0 Then	// 기본시간대의 요율만 있을 경우
	lc_bilamt = f_calc_basic(bsec, bfee, biltime, roundflag)
Else
	If pos > 0 AND pos <= rindex Then
		For i = 1 To pos - 1
			lc_bilamt += f_calc_range_full(range, sec, fee, roundflag, i)
		Next
		lc_bilamt += f_calc_range_partial(range, sec, fee, biltime, roundflag, pos)
	ElseIf pos > rindex Then
		For i = 1 To pos - 1
			lc_bilamt += f_calc_range_full(range, sec, fee, roundflag, i)
		Next
		lc_bilamt += f_calc_basic(bsec, bfee, biltime - ll_sum_range_b, roundflag)
	End If
End If

Return lc_bilamt
end function

public subroutine f_display_bilamt (long time, long unitsec, decimal unitfee, string roundflag, integer index);ib_display[index] = true
is_time[index] = String(time)
is_f[index] = String(time) + "/" + String(unitsec) + "=" &
					+ String(Round(time/unitsec, 2)) + " --> "

If roundflag = 'U' Then
	il_fsum += Round(0.499999 + time/unitsec, 0)
	is_f[index] += String(Round(0.499999 + time/unitsec, 0)) + " 도수(올림)"
	is_amt[index] = String(Round(0.499999 + time/unitsec, 0)) + " * " &
							+ String(unitfee) + " = " &
							+ String(Round(0.499999 + time/unitsec, 0) * unitfee)
ElseIf roundflag = 'D' Then
	il_fsum += Truncate(time/unitsec, 0)
	is_f[index] += String(Truncate(time/unitsec, 0)) + " 도수(절삭)"
	is_amt[index] = String(Truncate(time/unitsec, 0)) + " * " &
							+ String(unitfee) + " = " &
							+ String(Truncate(time/unitsec, 0) * unitfee)
Else
	il_fsum += Round(time/unitsec, 0)
	is_f[index] += String(Round(time/unitsec, 0)) + " 도수(반올림)"
	is_amt[index] = String(Round(time/unitsec, 0)) + " * " &
							+ String(unitfee) + " = " &
							+ String(Round(time/unitsec, 0) * unitfee)
End If
end subroutine

public function decimal f_calc_range_full (long range[], long sec[], decimal fee[], string roundflag, integer index);Dec lc_bilamt

If roundflag = 'U' Then
	lc_bilamt = Round(0.499999 + range[index]/sec[index], 0) * fee[index]
ElseIf roundflag = 'D' Then
	lc_bilamt = Truncate(range[index]/sec[index], 0) * fee[index]
Else
	lc_bilamt = Round(range[index]/sec[index], 0) * fee[index]
End If

f_display_bilamt(range[index], sec[index], fee[index], roundflag, index+1)

Return lc_bilamt
end function

public function long f_calc_usabletime (long bsec, decimal bfee, long range[], long sec[], long fee[], long balance, string roundflag);Int i, rindex, pos
long ll_amt[], ll_biltime

// 총 시간대
For i = 1 To 5
	If range[i] = 0 OR IsNull(range[i]) Then 
		rindex = i - 1
		Exit
	End If
Next

ll_biltime = 0
If rindex > 0 Then
	// balance가 속해있는 시간대를 찾는다.
	ll_amt[1] = f_calc_range_full(range, sec, fee, roundflag, 1)
	For i = 2 To rindex 
		ll_amt[i] = ll_amt[i - 1] + f_calc_range_full(range, sec, fee, roundflag, i)
	Next
	
	pos = 0
	For i = 1 To rindex
		If balance < ll_amt[i] Then
			pos = i
			Exit
		End If
	Next
	
	If pos = 0 Then
		pos = rindex + 1
	End If
	
	// 통화가능 시간 계산
	For i = 1 To pos - 1
		ll_biltime += range[i]
	Next
	
	If pos <= rindex Then
		If roundflag = 'U' Then
			ll_biltime += Truncate((balance - ll_amt[pos - 1])/fee[pos], 0) * sec[pos]
		ElseIf roundflag = 'D' Then
			ll_biltime += Truncate((balance - ll_amt[pos - 1])/fee[pos], 0) * sec[pos] + sec[pos] - 1
		Else
			ll_biltime += Truncate((balance - ll_amt[pos - 1])/fee[pos], 0) * sec[pos] + sec[pos]/2 - 1
		End If
	Else
		If roundflag = 'U' Then
			ll_biltime += Truncate((balance - ll_amt[pos - 1])/bfee, 0) * bsec
		ElseIf roundflag = 'D' Then
			ll_biltime += Truncate((balance - ll_amt[pos - 1])/bfee, 0) * bsec + bsec - 1
		Else
			ll_biltime += Truncate((balance - ll_amt[pos - 1])/bfee, 0) * bsec + bsec/2 - 1
		End If
	End If
Else
	If roundflag = 'U' Then
		ll_biltime = Truncate(balance/bfee, 0) * bsec
	ElseIf roundflag = 'D' Then
		ll_biltime = Truncate(balance/bfee, 0) * bsec + bsec - 1
	Else
		ll_biltime = Truncate(balance/bfee, 0) * bsec + bsec/2 - 1
	End If
End If

Return ll_biltime
end function

public function decimal f_calc_basic (long bsec, decimal bfee, long biltime, string roundflag);Dec lc_bilamt

If roundflag = 'U' Then
	lc_bilamt = Round(0.499999 + biltime/bsec, 0) * bfee
ElseIf roundflag = 'D' Then
	lc_bilamt = Truncate(biltime/bsec, 0) * bfee
Else
	lc_bilamt = Round(biltime/bsec, 0) * bfee
End If

f_display_bilamt(biltime, bsec, bfee, roundflag, 1)

Return lc_bilamt
end function

on b0w_cal_rating.create
call super::create
end on

on b0w_cal_rating.destroy
call super::destroy
end on

event type integer ue_input();call super::ue_input;String ls_nodeno, ls_rtelnum, ls_priceplan, ls_balance
DateTime ldt_stime
Long ll_biltime, ll_balance
String ls_stime, ls_biltime


ls_nodeno = Trim(dw_input.object.nodeno[1])
ls_rtelnum = Trim(dw_input.object.rtelnum[1])
ls_stime = String(dw_input.object.stime[1])
ls_biltime = String(dw_input.object.biltime[1])
ls_balance = String(dw_input.object.balance[1])
ls_priceplan = Trim(dw_input.object.priceplan[1])
ldt_stime = dw_input.object.stime[1]

If IsNull(ls_nodeno) Then ls_nodeno = ""
If IsNull(ls_rtelnum) Then ls_rtelnum = ""
If IsNull(ls_stime) Then ls_stime = ""
If IsNull(ls_biltime) Then ls_biltime = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_balance) Then ls_balance = ""

// 필수입력 체크
If ls_nodeno = "" Then
	f_msg_usr_err(200, This.Title, "발신지")
	dw_input.setRow(1)
	dw_input.setColumn("nodeno")
	dw_input.setFocus()
	Return -1
End If
If ls_rtelnum = "" Then
	f_msg_usr_err(200, This.Title, "착신번호")
	dw_input.setRow(1)
	dw_input.setColumn("rtelnum")
	dw_input.setFocus()
	Return -1
End If
If ls_stime = "" Then
	f_msg_usr_err(200, This.Title, "통화시작시각")
	dw_input.setRow(1)
	dw_input.setColumn("stime")
	dw_input.setFocus()
	Return -1
End If
If ls_priceplan = "" Then
	f_msg_usr_err(200, This.Title, "가격정책")
	dw_input.setRow(1)
	dw_input.setColumn("priceplan")
	dw_input.setFocus()
	Return -1
End If
If (ls_biltime = "" AND ls_balance = "") OR (ls_biltime <> "" AND ls_balance <> "") Then
	f_msg_usr_err(9000, This.Title, "통화시간 또는 잔액중 한가지만을 입력해 주세요.")
	dw_input.setRow(1)
	dw_input.setColumn("biltime")
	dw_input.setFocus()
	Return -1
End If

Return 0
end event

event type integer ue_process();call super::ue_process;String ls_nodeno, ls_rtelnum, ls_priceplan, ls_roundflag, ls_customerid, ls_partner
String ls_ratetype, ls_zoncod, ls_info, ls_tmp, ls_tmcod
DateTime ldt_stime
Long ll_biltime, ll_balance
Long ll_bsec, ll_mbsec, ll_unbilsec
Dec lc_bfee, lc_bilamt, lc_mbfee
Long ll_range[], ll_sec[], ll_mrange[], ll_msec[]
Long ll_idx, p, q
Int li_rc
Dec lc_fee[], lc_mfee[]
b0u_dbmgr lu_dbmgr

ls_nodeno = Trim(dw_input.object.nodeno[1])
ls_rtelnum = Trim(dw_input.object.rtelnum[1])
ldt_stime = dw_input.object.stime[1]
ll_biltime = Long(dw_input.object.biltime[1])
ll_balance = Long(dw_input.object.balance[1])
ls_priceplan = Trim(dw_input.object.priceplan[1])
ls_customerid = Trim(dw_input.object.customerid[1])
ls_partner = Trim(dw_input.object.partner[1])

lu_dbmgr = Create b0u_dbmgr
lu_dbmgr.is_title = This.Title
lu_dbmgr.is_caller = "b0w_cal_rating"
lu_dbmgr.is_data[1] = ls_nodeno
lu_dbmgr.is_data[2] = ls_rtelnum
lu_dbmgr.is_data[3] = ls_priceplan
lu_dbmgr.is_data[4] = ls_customerid
lu_dbmgr.is_data[5] = ls_partner
lu_dbmgr.idt_data[1] = ldt_stime

lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then 
	Return li_rc
End If

// 기본 시간단위, 요율
ll_bsec = lu_dbmgr.il_data[11]
lc_bfee = lu_Dbmgr.ic_data[6]

// 멘트용 기본 시간단위, 요율
ll_mbsec = lu_dbmgr.il_data[22]
lc_mbfee = lu_dbmgr.ic_data[12]

// 비과금초
ll_unbilsec = lu_dbmgr.il_data[23]

// 시간대별 시간범위, 단위시간, 요금
p = 1
q = 1
For ll_idx = 1 To 5
	ll_range[ll_idx] = lu_dbmgr.il_data[p]
	ll_sec[ll_idx] = lu_dbmgr.il_data[p+1]
	lc_fee[ll_idx] = lu_dbmgr.ic_data[q]
	ll_mrange[ll_idx] = lu_dbmgr.il_data[P+11]
	ll_msec[ll_idx] = lu_dbmgr.il_data[P+12]
	lc_mfee[ll_idx] = lu_dbmgr.ic_data[q+6]
	p += 2
	q++
Next

// 사용요금 계산
If IsNull(ll_balance) Then	// 통화시간을 입력한 경우
	If ll_biltime > ll_unbilsec Then	// 통화시간이 비과금초보다 크면
		lc_bilamt = f_calc_bilamt(ll_bsec, lc_bfee, ll_range, ll_sec, lc_fee, ll_biltime, ls_roundflag)
	End If
Else 		// 잔액을 입력한 경우 --> 사용가능 시간 계산
	ll_biltime = f_calc_usabletime(ll_bsec, lc_bfee, ll_range, ll_sec, lc_fee, ll_balance, ls_roundflag)
	il_fsum = 0
	lc_bilamt = f_calc_bilamt(ll_bsec, lc_bfee, ll_range, ll_sec, lc_fee, ll_biltime, ls_roundflag)
End If

// Roundflag
ls_roundflag = lu_dbmgr.is_data[6]

// 적용된 요율
ls_ratetype = lu_dbmgr.is_data[7]
ls_info = lu_dbmgr.is_data[8]

// 대역
ls_zoncod = lu_dbmgr.is_data[9]

// 시간대
ls_tmcod = lu_dbmgr.is_data[10]

Destroy lu_dbmgr

Choose Case ls_ratetype
	Case 'Std'
		ls_tmp = '표준요율'
	Case 'Cus'
		ls_tmp = '고객별요율(고객번호:' + ls_info + ')'
	Case 'Ptn'
		ls_tmp = '대리점별요율(대리점ID:' + ls_info + ')'
	Case 'Prc'
		ls_tmp = '가격정책별요율(가격정책:' + ls_info + ') '
End Choose


/********************************* Display Start ************************************/
// 기본정보 Display
is_msg_ratetype = ls_tmp
is_msg_zoncod = ls_zoncod
is_msg_tmcod = ls_tmcod
dw_msg_processing.object.priceplan[1] = ls_priceplan

// 요율정보 display
dw_msg_processing.object.bsec[1] = ll_bsec
dw_msg_processing.object.bfee[1] = lc_bfee

dw_msg_processing.object.range1[1] = ll_range[1]
dw_msg_processing.object.sec1[1] = ll_sec[1]
dw_msg_processing.object.fee1[1] = lc_fee[1]
dw_msg_processing.object.range2[1] = ll_range[2]
dw_msg_processing.object.sec2[1] = ll_sec[2]
dw_msg_processing.object.fee2[1] = lc_fee[2]
dw_msg_processing.object.range3[1] = ll_range[3]
dw_msg_processing.object.sec3[1] = ll_sec[3]
dw_msg_processing.object.fee3[1] = lc_fee[3]
dw_msg_processing.object.range4[1] = ll_range[4]
dw_msg_processing.object.sec4[1] = ll_sec[4]
dw_msg_processing.object.fee4[1] = lc_fee[4]
dw_msg_processing.object.range5[1] = ll_range[5]
dw_msg_processing.object.sec5[1] = ll_sec[5]
dw_msg_processing.object.fee5[1] = lc_fee[5]


dw_msg_processing.object.mbsec[1] = ll_mbsec
dw_msg_processing.object.mbfee[1] = lc_mbfee

dw_msg_processing.object.mrange1[1] = ll_mrange[1]
dw_msg_processing.object.msec1[1] = ll_msec[1]
dw_msg_processing.object.mfee1[1] = lc_mfee[1]
dw_msg_processing.object.mrange2[1] = ll_mrange[2]
dw_msg_processing.object.msec2[1] = ll_msec[2]
dw_msg_processing.object.mfee2[1] = lc_mfee[2]
dw_msg_processing.object.mrange3[1] = ll_mrange[3]
dw_msg_processing.object.msec3[1] = ll_msec[3]
dw_msg_processing.object.mfee3[1] = lc_mfee[3]
dw_msg_processing.object.mrange4[1] = ll_mrange[4]
dw_msg_processing.object.msec4[1] = ll_msec[4]
dw_msg_processing.object.mfee4[1] = lc_mfee[4]
dw_msg_processing.object.mrange5[1] = ll_mrange[5]
dw_msg_processing.object.msec5[1] = ll_msec[5]
dw_msg_processing.object.mfee5[1] = lc_mfee[5]


// 사용요금계산 display
If ib_display[1] Then
	dw_msg_processing.object.t_time0.text = is_time[1]
	dw_msg_processing.object.t_f0.text = is_f[1]
	dw_msg_processing.object.t_amt0.text = is_amt[1]
End If
If ib_display[2] Then
	dw_msg_processing.object.t_time1.text = is_time[2]
	dw_msg_processing.object.t_f1.text = is_f[2]
	dw_msg_processing.object.t_amt1.text = is_amt[2]
End If
If ib_display[3] Then
	dw_msg_processing.object.t_time2.text = is_time[3]
	dw_msg_processing.object.t_f2.text = is_f[3]
	dw_msg_processing.object.t_amt2.text = is_amt[3]
End If
If ib_display[4] Then
	dw_msg_processing.object.t_time3.text = is_time[4]
	dw_msg_processing.object.t_f3.text = is_f[4]
	dw_msg_processing.object.t_amt3.text = is_amt[4]
End If
If ib_display[5] Then
	dw_msg_processing.object.t_time4.text = is_time[5]
	dw_msg_processing.object.t_f4.text = is_f[5]
	dw_msg_processing.object.t_amt4.text = is_amt[5]
End If
If ib_display[6] Then
	dw_msg_processing.object.t_time5.text = is_time[6]
	dw_msg_processing.object.t_f5.text = is_f[6]
	dw_msg_processing.object.t_amt5.text = is_amt[6]
End If

dw_msg_processing.object.t_timesum.text = String(ll_biltime)
dw_msg_processing.object.t_fsum.text = String(il_fsum)
dw_msg_processing.object.t_amtsum.text = String(lc_bilamt)

// 멘트용 사용요금 계산
If IsNull(ll_balance) Then
	If ll_biltime > ll_unbilsec Then	// 통화시간이 비과금초보다 크면
		il_fsum = 0
		lc_bilamt = f_calc_bilamt(ll_mbsec, lc_mbfee, ll_mrange, ll_msec, lc_mfee, ll_biltime, ls_roundflag)
	End If
Else
	ll_biltime = f_calc_usabletime(ll_mbsec, lc_mbfee, ll_mrange, ll_msec, lc_mfee, ll_balance, ls_roundflag)
	il_fsum = 0
	lc_bilamt = f_calc_bilamt(ll_mbsec, lc_mbfee, ll_mrange, ll_msec, lc_mfee, ll_biltime, ls_roundflag)
End If


// 멘트용 사용요금 계산 display
If ib_display[1] Then
	dw_msg_processing.object.t_mtime0.text = is_time[1]
	dw_msg_processing.object.t_mf0.text = is_f[1]
	dw_msg_processing.object.t_mamt0.text = is_amt[1]
End If
If ib_display[2] Then
	dw_msg_processing.object.t_mtime1.text = is_time[2]
	dw_msg_processing.object.t_mf1.text = is_f[2]
	dw_msg_processing.object.t_mamt1.text = is_amt[2]
End If
If ib_display[3] Then
	dw_msg_processing.object.t_mtime2.text = is_time[3]
	dw_msg_processing.object.t_mf2.text = is_f[3]
	dw_msg_processing.object.t_mamt2.text = is_amt[3]
End If
If ib_display[4] Then
	dw_msg_processing.object.t_mtime3.text = is_time[4]
	dw_msg_processing.object.t_mf3.text = is_f[4]
	dw_msg_processing.object.t_mamt3.text = is_amt[4]
End If
If ib_display[5] Then
	dw_msg_processing.object.t_mtime4.text = is_time[5]
	dw_msg_processing.object.t_mf4.text = is_f[5]
	dw_msg_processing.object.t_mamt4.text = is_amt[5]
End If
If ib_display[6] Then
	dw_msg_processing.object.t_mtime5.text = is_time[6]
	dw_msg_processing.object.t_mf5.text = is_f[6]
	dw_msg_processing.object.t_mamt5.text = is_amt[6]
End If

dw_msg_processing.object.t_mtimesum.text = String(ll_biltime)
dw_msg_processing.object.t_mfsum.text = String(il_fsum)
dw_msg_processing.object.t_mamtsum.text = String(lc_bilamt)

/********************************* Display End ************************************/

Return li_rc
end event

event type integer ue_pre_complete();DateTime ldt_start_time, ldt_end_time

dw_msg_time.Object.end_time[1] = fdt_get_dbserver_now()

ldt_start_time = dw_msg_time.Object.start_time[1]
ldt_end_time = dw_msg_time.Object.end_time[1]

dw_msg_time.Object.eclipsed_time[1] = &
 RelativeTime(Time("00:00:00"), SecondsAfter(Time(ldt_start_time), Time(ldt_end_time)) + &
  DaysAfter(Date(ldt_start_time), Date(ldt_end_time)) * 24 * 3600  )

dw_msg_processing.Object.ratetype[1] = is_msg_ratetype
dw_msg_processing.Object.zoncod[1] = is_msg_zoncod
dw_msg_processing.Object.tmcod[1] = is_msg_tmcod

Return 0

end event

event ue_ok();Integer li_rc
int i

//***** 초기화 작업 *****
SetPointer(HourGlass!)

//***** 입력 부분 *****
If dw_input.AcceptText() < 0 Then
	dw_input.SetFocus()
	Return
End If

If This.Trigger Event ue_input() < 0 Then
//	//Input Mode로
//	Trigger Event ue_chg_mode("INPUT")
	Return
End If

//실행의 확인 작업
li_rc = f_msg_ques_yesno2(il_msg_no, Title, is_msg_text, 1)

If li_rc <> 1 Then
//	//Input Mode로
//	Trigger Event ue_chg_mode("INPUT")
	Return
End If

//***** Process부분 *****
//Process Mode로
Trigger Event ue_chg_mode("PROCESS")

//Process call
li_rc = Trigger Event ue_process()

If li_rc < 0 Then
	Trigger Event ue_chg_mode("INPUT")
Else
	If Trigger Event ue_pre_complete() < 0 Then
		//Input Mode로
		Trigger Event ue_chg_mode("INPUT")
		f_msg_info(3010, Title, iu_cust_msg.is_pgm_name)
	Else
		//Completed Mode로
		Trigger Event ue_chg_mode("COMPLETED")
	End If
End If


// 초기화
For i = 1 To 6
	ib_display[i] = False
	is_time[i] = ""
	is_f[i] = ""
	is_amt[i] = ""
Next

il_fsum = 0
end event

event open;call super::open;int i

// 초기화
For i = 1 To 6
	ib_display[i] = False
Next

il_fsum = 0
end event

type p_ok from w_a_prc`p_ok within b0w_cal_rating
integer x = 2487
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b0w_cal_rating
integer x = 59
integer width = 2217
integer height = 392
string dataobject = "b0dw_cnd_cal_rating"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_input.iu_cust_help.ib_data[1] Then
			 dw_input.Object.customerid[row] = &
			 dw_input.iu_cust_help.is_data[1]
		End If
//	Case "partner"
//		If dw_input.iu_cust_help.ib_Data[1] Then
//			dw_input.object.partner[row] = &
//			dw_input.iu_cust_help.is_data[1]
//		End If
End Choose

Return 0
end event

event dw_input::ue_init();call super::ue_init;dw_input.is_help_win[1] = "b1w_hlp_customerm"
dw_input.idwo_help_col[1] = dw_input.Object.customerid
dw_input.is_data[1] = "CloseWithReturn"

//dw_input.is_help_win[2] = "b2w_hlp_partnermst"
//dw_input.idwo_help_col[2] = dw_input.Object.partner
//dw_input.is_data[2] = "CloseWithReturn"
//

end event

type dw_msg_time from w_a_prc`dw_msg_time within b0w_cal_rating
boolean visible = false
integer x = 23
integer y = 796
integer width = 2117
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b0w_cal_rating
integer y = 460
integer width = 3685
integer height = 1736
string dataobject = "b0dw_msg_calc_rating"
end type

type ln_up from w_a_prc`ln_up within b0w_cal_rating
integer beginy = 448
integer endx = 2231
integer endy = 448
end type

type ln_down from w_a_prc`ln_down within b0w_cal_rating
integer beginy = 2260
integer endy = 2260
end type

type p_close from w_a_prc`p_close within b0w_cal_rating
integer x = 2487
integer y = 144
end type

type gb_cond from w_a_prc`gb_cond within b0w_cal_rating
integer width = 2277
integer height = 440
end type

