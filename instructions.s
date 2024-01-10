	.syntax unified
	.arch   armv7   @ обратить внимание; указали минимально требуемый, используемый (совместимый) набор команд


	/* Эффективная реализация */
	@.global raminit
	/* На примере условного перехода */
	@.global raminit_b


	.text
	.thumb

# Объявим псевдонимы регистров
src     .req    a1  @ r0, как адрес источника
dst     .req    a2  @ r1, как адрес назначения
end     .req    a3  @ r2, как адрес конца блока - адрес следующей ячейки за последней в блоке назначения

/* Процедура инициализации блока ОЗУ 
 * Все адрес должны быть выровнены по границе 4х байт (выравнивание по ячейке памяти).
 * Это сделано для эффективности и упрощения.
 * За соблюдением выполнения условия следит разработчик.
 *
 * Вероятно, это более эффективное решение, так как инструкция IT 
 * присоединённая к CMP не отнимает дополнительных циклов ядра.
 * Также, IT в отличии от Branch не вызывает очистку конвейера.
 * Инструкции, охваченные блоком IT пропускаются единственный раз, 
 * непосредственно перед выходом из функции.
 */
	.thumb_func             @ Функция набора команд thumb
	.type   raminit, %function
raminit:
.L_loop1:
	cmp     dst, end        @ Сравнить адрес назнчения с последним адресом
	ittt    lt              @ Инструкция IT - блок условий: 3 условных инструкции (if `less`: 1. всегда then, 2. T:then, 3. T:then)
	ldrlt   r3, [src], #4   @ Если меньше, то выполнить: загрузка значения в R3 из памяти по адресу в `src` (r0) и увелчиение `src` на 4.
	strlt   r3, [dst], #4   @ Если меньше, то выполнить: загрузка значения из R3 в память по адресу в `dst` (r1) и увелчиение `dst` на 4.
	blt     .L_loop1        @ Если меньше, то выполнить (Уловие будет проверено, и blt будет заменён на b)
	bx      lr              @ Возврат
	.size   raminit, . - raminit


/* 
 * Альтернативный вариант, с использованием условного branch,
 * но стоит сравнить скорость работы.
 * P.S.: тут использован другой вид локальных меток (имя генерируется аватоматически, 
 * действуют, до появления следующей глобальной метки).
 */
	.thumb_func             @ Функция набора команд thumb
	.type   raminit_b, %function
raminit_b:
1$:     @ Локальная метка 1 (".L...")
	cmp     dst, end        @ Сравнить адрес назнчения с последним адресом
	bge     2$              @ Перейти на выход, если адрес в dst больше, чем в end.
	ldr     r3, [src], #4   @ Загрузка значения в R3 из памяти по адресу в `src` (r0) и увелчиение `src` на 4.
	str     r3, [dst], #4   @ Загрузка значения из R3 в память по адресу в `dst` (r1) и увелчиение `dst` на 4.
	b       1$              @ Перейти к началу цикла.
2$:     @ Локальная метка 2 (".L...")
	bx      lr              @ Возврат
	.size   raminit_b, . - raminit_b


	.type   ex_move, %function
	@.global ex_move
	.thumb_func
ex_move:
	# Премещение значений регистров (MOVE)
	# Непосредственные значения в код (в инструкции)
	# > ВАЖНО: Поле
	mov	r0, #0
	mov 	r1, #255			@ Запись в регистр R1 непосредственного значения в десятичной форме
	mov 	r2, #0xF0			@ Запись в регистр R2 непосредственного значения в шестнадцатеричной форме
	
	mov	r1, #256
	movw	r2, #0x100

	movw	r3, #0x100
	movw	r3, #0xFFFF

	# Копирование значений из одного регистра в другой
	mov 	r0, r1				@ Запись в регистр R0 значени из R1

	/* Фокус 2: Синонимы регистров (A1-A4, V1-V8) */
	mov 	A1, R2				@ Запись в регистр R0 (он же A1), значения из регистра R2
	add 	R3, R1, R2			@ Сумма
	sub 	R3, R2
	adds 	R3, R1, R2
	subs 	R4, R3, R2

	bx	lr
	.size	ex_move, . - ex_move

	.end                    @ Конец файла. Всё, что ниже, - не транслируется
