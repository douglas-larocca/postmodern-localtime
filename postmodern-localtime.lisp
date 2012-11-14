(defpackage #:postmodern-localtime
	(:use #:cl #:postmodern #:local-time))


(in-package #:postmodern-localtime)

(defconstant +postgres-day-offset-to-local-time+ -60)

(defun set-local-time-cl-postgres-readers (&optional (table cl-postgres:*sql-readtable*))
  (flet ((timestamp-reader (usecs)
           (multiple-value-bind (days usecs)
               (floor usecs local-time::+usecs-per-day+)
             (multiple-value-bind (secs usecs)
                 (floor usecs 1000000)
               (local-time:make-timestamp :nsec (* usecs 1000)
                                          :sec secs
                                          :day (+ days +postgres-day-offset-to-local-time+)))))
	     (timestamp-without-timezone-reader (usecs)
			(local-time:timestamp-to-unix
				(multiple-value-bind (days usecs)
					(floor usecs local-time::+usecs-per-day+)
					(multiple-value-bind (secs usecs)
						(floor usecs 1000000)
						(with-decoded-timestamp (:nsec nsec :sec sec :minute minute :hour hour :day day :month month :year year :timezone +utc-zone+) 
												(local-time:make-timestamp 
													:nsec (* usecs 1000)
													:sec secs
													:day (+ days +postgres-day-offset-to-local-time+))
							(encode-timestamp nsec sec minute hour day month year)))))))
    (cl-postgres:set-sql-datetime-readers
     :table table
     :date (lambda (days)
             (local-time:make-timestamp
              :nsec 0 :sec 0
              :day (+ days +postgres-day-offset-to-local-time+)))
     :timestamp #'timestamp-without-timezone-reader ;#'timestamp-reader
     :timestamp-with-timezone #'timestamp-without-timezone-reader ;#'timestamp-reader
	; :timestamp-without-timezone #'timestamp-without-timezone-reader
     :interval
     (lambda (months days usecs)
       (declare (ignore months days usecs))
       (error "Intervals are not yet supported"))
     :time
     (lambda (usecs)
       (multiple-value-bind (days usecs)
           (floor usecs +usecs-per-day+)
         (assert (= days 0))
         (multiple-value-bind (secs usecs)
             (floor usecs 1000000)
           (let ((time-of-day (local-time:make-timestamp
                               :nsec (* usecs 1000)
                               :sec secs
                               :day 0)))
             (check-type time-of-day time-of-day)
             time-of-day)))))))

(defmethod cl-postgres:to-sql-string ((arg local-time:timestamp))
	(format nil "'~a'"
         (local-time:format-rfc3339-timestring nil arg :omit-timezone-part nil))) ; :timezone local-time:+utc-zone+)))
		 
(defmethod cl-postgres:to-sql-string ((arg number))
	(format nil "'~a'"
         (local-time:format-rfc3339-timestring nil (local-time:unix-to-timestamp arg) :omit-timezone-part nil))) ; :timezone local-time:+utc-zone+)))

(set-local-time-cl-postgres-readers)
