#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
using System.Diagnostics;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "FrameRunner", Category = "Animation", Version = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueAnimationFrameRunnerNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Play")]
		public IDiffSpread<bool> FInPlay;
		
		[Input("Loop")]
		public IDiffSpread<bool> FInLoop;

		[Input("Reset", IsBang = true)]
		public ISpread<bool> FInReset;

		[Input("In Point")]
		public ISpread<int> FInIn;
		
		[Input("Out Point")]
		public ISpread<int> FInOut;
		
		[Input("Frame Rate")]
		public ISpread<double> FInFrameRate;
			
		[Output("Frame Index")]
		public ISpread<int> FOutFrameIndex;
		
		[Output("Time")]
		public ISpread<double> FOutTime;
		
		[Import()]
		public ILogger FLogger;
		#endregion fields & pins

		Stopwatch FStopWatch = new Stopwatch();
		int FStartOffset = 0;
		
		//called when data for any output pin is requested
		void Reset()
		{
			//reset to offset time
			if(this.FInPlay[0]) {
				this.FStopWatch.Restart();
			}
			else {
				this.FStopWatch.Reset();
				FStartOffset = FInIn[0];
			}
		}
		
		bool FFirstFrame = true;
		public void Evaluate(int SpreadMax)
		{
			if(FFirstFrame) {
				this.Reset();
				FFirstFrame = false;
			}
			
			if(FInPlay.IsChanged) {
				if(FInPlay[0]) {
					this.FStopWatch.Start();
				} else {
					this.FStopWatch.Stop();
				}
			}
			
			if(FInReset[0]) {
				this.Reset();
			}
			
			var time = this.FStopWatch.Elapsed.TotalSeconds;
			time += (double)FStartOffset / FInFrameRate[0];

			int frameIndex = (int) (time * FInFrameRate[0]);
			
			if(FStopWatch.IsRunning && frameIndex >= FInOut[0] - 1) {
				if(FInLoop[0]) {
					this.Reset();
					//don't change the playback rate during loop frame
					FStartOffset = (frameIndex - FInOut[0]) + FInIn[0];
					
					frameIndex = FStartOffset;
				} else {
					FStopWatch.Stop();
					frameIndex = FInOut[0] - 1;
				}
			}
			
			if(frameIndex < FInIn[0]) {
				//in must have been changed
				frameIndex = FInIn[0];
				this.Reset();
				FStartOffset = frameIndex;
			}
			
			FOutFrameIndex[0] = frameIndex;
			FOutTime[0] = time;
		}
	}
}
