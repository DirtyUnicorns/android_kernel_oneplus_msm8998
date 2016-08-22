/// Check for hard-coded numeric timeout values which are thus HZ dependent
//# Only report findings if the value is digits and != 1 as hard-coded
//# 1 seems to be in use for short delays.
//#
//# For kernel API that expects jiffies to be passed in a hard-coded value
//# makes the effective timeout dependent on the compile-time HZ setting
//# which is wrong in most (all?) cases. Any timeout should be passed
//# through msecs_to_jiffies() or usecs_to_jiffies() to make the timeout
//# values HZ independent.
//#
//# No patch mode for this, as converting the value from C to
//# msecs_to_jiffies(C) could be changing the effective timeout by more
//# than a factor of 10 so this always needs manual inspection. Most notably
//# code that pre-dates variable HZ (prior to 2.4 kernel series) had HZ=100
//# so a constant of 10 should be converted to 100ms for any old driver.
//#
//# In some cases C-constants are passed in that are not converted to
//# jiffies, to locate these cases run in MODE=strict in which case these
//# will also be reported except if HZ is passed. Note though many are
//# likely to be false positives !
//
// Confidence: Medium
// Copyright: (C) 2015 Nicholas Mc Guire <hofrat@osadl.org>, OSADL, GPL v2
// URL: http://coccinelle.lip6.fr
// Options: --no-includes --include-headers

virtual org
virtual report
virtual strict
virtual patch

@cc depends on !patch && (org || report || strict)@
constant int C;
position p;
@@

(
schedule_timeout@p(C)
|
schedule_timeout_interruptible@p(C)
|
schedule_timeout_killable@p(C)
|
schedule_timeout_uninterruptible@p(C)
|
mod_timer(...,C)
|
mod_timer_pinned(...,C)
|
mod_timer_pending(...,C)
|
apply_slack(...,C)
|
queue_delayed_work(...,C)
|
mod_delayed_work(...,C)
|
schedule_delayed_work_on(...,C)
|
schedule_delayed_work(...,C)
|
schedule_timeout(C)
|
schedule_timeout_interruptible(C)
|
schedule_timeout_killable(C)
|
schedule_timeout_uninterruptibl(C)
|
wait_event_timeout(...,C)
|
wait_event_interruptible_timeout(...,C)
|
wait_event_uninterruptible_timeout(...,C)
|
wait_event_interruptible_lock_irq_timeout(...,C)
|
wait_on_bit_timeout(...,C)
|
wait_for_completion_timeout(...,C)
|
wait_for_completion_io_timeout(...,C)
|
wait_for_completion_interruptible_timeout(...,C)
|
wait_for_completion_killable_timeout(...,C)
)

@script:python depends on org@
p << cc.p;
timeout << cc.C;
@@

# schedule_timeout(1) for a "short" delay is not really HZ dependent
# as it always would be converted to 1 by msecs_to_jiffies as well
# so count this as false positive
if str.isdigit(timeout):
   if (int(timeout) != 1):
      msg = "WARNING: timeout is HZ dependent"
      coccilib.org.print_safe_todo(p[0], msg)

@script:python depends on report@
p << cc.p;
timeout << cc.C;
@@

if str.isdigit(timeout):
   if (int(timeout) != 1):
      msg = "WARNING: timeout (%s) seems HZ dependent" % (timeout)
      coccilib.report.print_report(p[0], msg)

@script:python depends on strict@
p << cc.p;
timeout << cc.C;
@@

# "strict" mode prints the cases that use C-constants != HZ
# as well as the numeric constants != 1. This will deliver a false
# positives if the C-constant is already in jiffies !
if str.isdigit(timeout):
   if (int(timeout) != 1):
      msg = "WARNING: timeout %s is HZ dependent" % (timeout)
      coccilib.report.print_report(p[0], msg)
elif (timeout != "HZ"):
   msg = "INFO: timeout %s may be HZ dependent" % (timeout)
   coccilib.report.print_report(p[0], msg)
