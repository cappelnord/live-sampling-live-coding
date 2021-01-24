var options = (
	inChannel: 0,
	monitChannel: 0,
	dir: Document.current.dir +/+ "samples"
);


var bufferInfo = ();
~buf = ();

~bufRemove = {|key|

	bufferInfo[key] = nil;
	~buf[key].free;
	~buf[key] = nil;

	// keep files on disk
};

~bufInit = {|o|
	bufferInfo.keys.do {|key|
		~bufRemove.value(key);
	};
	options = o;
	bufferInfo = ();
	~buf = ();
};

~bufRecord = {|key, dur=1|
	bufferInfo[key].isNil.not.if ({
		("overwriting " ++ key ++ "!").postln;
		((bufferInfo.dur != dur) && bufferInfo.dur.isNil.not).if {
			"duration mismatch; using old duration!".postln;
			dur = bufferInfo.dur;
		};
	}, {
		bufferInfo[key] = (buf: Buffer.alloc(s, s.sampleRate * dur, 1));
		~buf[key] = bufferInfo[key].buf;
	});

	bufferInfo[key].dur = dur;

	Synth(\record, [\in, options.inChannel, \buffer, ~buf[key], \dur, dur]);

	fork {
		var fileName = options.dir +/+ key.asString ++ ".aiff";
		(0.5 + (dur / TempoClock.default.tempo)).wait;
		~buf[key].write(fileName);
		fileName.postln;
	};
};

~bufMonit = {|key|
	Synth(\monit, [\out, options.monitChannel, \buffer, ~buf[key]]);
};

~bufRestore = {
	var files = PathName(options.dir).files.collect {|x| x.fileName};
	~bufInit.(options);
	files.do {|filename|
		var key = filename.split($.)[0].asSymbol;
		var path = options.dir +/+ filename;
		var sf = SoundFile.openRead(path);
		var dur = sf.duration;

		var buffer = Buffer.read(s, path);

		bufferInfo[key] = (buf: buffer, dur: dur);
		~buf[key] = buffer;

		(filename ++ " loaded ...").postln;
		sf.close;
	};
};


SynthDef(\record, {|in=0, buffer=0, dur=1|
	var sig = Mix.ar(SoundIn.ar(in, 2)) * 0.5;
	var env = EnvGen.ar(Env([0, 1, 1, 0], [0.02, dur-0.04, 0.02]), doneAction: 2);
	RecordBuf.ar(sig * env, buffer);
}).add;

SynthDef(\monit, {|out=0, buffer=0, amp=1|
	var sig = PlayBuf.ar(1, buffer, 1, doneAction:1);
	Out.ar(out, sig.dup * amp);
}).add;
