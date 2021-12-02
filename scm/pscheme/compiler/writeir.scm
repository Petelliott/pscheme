(define-library (pscheme compiler writeir)
  (import (scheme base)
          (scheme write))
  (export writeir)
  (begin

    (define (writeir forms port)
      (for-each (lambda (form)
                  (writeir-form form port 0)
                  (newline port)
                  (newline port))
                forms))

    (define (indent n port)
      (when (> n 0)
        (display " " port)
        (indent (- n 1) port)))

    (define (indented-block forms port n)
      (for-each (lambda (f)
                  (newline port)
                  (indent n port)
                  (writeir-form f port n))
                forms))

    (define (writeir-form form port i)
      (if (pair? form)
          (case (car form)
            ((begin)   (writeir-begin form port i))
            ((define lambda define-library)  (writeir-lambda form port i))
            ((set! call if import export) (writeir-eachline form port i))
            ((closure) (writeir-closure form port i))
            (else (write form port)))
          (write form port)))

    (define (writeir-begin form port i)
      (display "(" port)
      (display (car form) port)
      (indented-block (cdr form) port (+ i 2))
      (display ")" port))

    (define (writeir-lambda form port i)
      (display "(" port)
      (display (car form) port)
      (display " " port)
      (write (cadr form) port)
      (indented-block (cddr form) port (+ i 2))
      (display ")" port))

    (define (writeir-eachline form port i)
      (define newi (+ i 2 (string-length (symbol->string (car form)))))
      (display "(" port)
      (display (car form) port)
      (display " " port)
      (writeir-form (cadr form) port newi)
      (indented-block (cddr form) port newi)
      (display ")" port))

    (define (writeir-closure form port i)
      (define newi (+ i 2 (string-length (symbol->string (car form)))))
      (display "(" port)
      (display (car form) port)
      (display " " port)
      (writeir-form (cadr form) port newi)
      (newline port)
      (indent newi port)
      (write (cddr form) port)
      (display ")" port))

    ))
