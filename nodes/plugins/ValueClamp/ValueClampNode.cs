#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "Clamp", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueClampNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultValue = 1.0)]
		public ISpread<double> FInput;

		[Input("Minimum", DefaultValue = 0.0)]
		public ISpread<double> FInMin;

		[Input("Maximum", DefaultValue = 1.0)]
		public ISpread<double> FInMax;
		
		[Output("Output")]
		public ISpread<double> FOutput;

		[Import()]
		public ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = SpreadMax;

			for (int i = 0; i < SpreadMax; i++)
			{
				var min = FInMin[i];
				if (min < FInput[i]) {
					var max = FInMax[i];
					if (max > FInput[i]) {
						FOutput[i] = FInput[i];
					} else {
						FOutput[i] = max;
					}
				} else {
					FOutput[i] = min;
				}
			}
		}
	}
}
