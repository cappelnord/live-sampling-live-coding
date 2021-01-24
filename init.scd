"buf.scd".loadRelative

(
~bufInit.value((
	inChannel: 0,
	monitChannel: 0,
	dir: Document.current.dir +/+ "samples"
));
)

~bufRestore.();