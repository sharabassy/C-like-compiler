using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;
using System.Windows;

namespace GUI
{
    public partial class Form1 : Form
    {
        ProcessStartInfo cmdProcess =new ProcessStartInfo();
        string file_name;

        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {

            cmdProcess.FileName = "cmd.exe";
            cmdProcess.UseShellExecute = false;
            cmdProcess.RedirectStandardOutput = true;
            cmdProcess.Arguments = "/c cmp.exe < " + file_name;
            using (Process process = Process.Start(cmdProcess))
            {
                using (StreamReader reader = process.StandardOutput)
                {
                    string result = reader.ReadToEnd();
                    textBox2.Text = result;
                    System.IO.File.WriteAllText(@"D:\\GnuWin32\\bin\\output.txt", result);

                }
            }
          
        }


        private void button3_Click(object sender, EventArgs e)
        {
            textBox1.Clear();
            textBox2.Clear();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            int size = -1;
            DialogResult result = openFileDialog1.ShowDialog();
            if (result == DialogResult.OK)
            {
                file_name = openFileDialog1.FileName;

                file_name = file_name.Replace(@"\", @"\\");
                try
                {
                    string text = File.ReadAllText(file_name);
                    textBox1.Text = text;
                    size = text.Length;
                }
                catch (IOException)
                {
                }
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.MinimumSize = new System.Drawing.Size(this.Width, this.Height);

            this.AutoSize = true;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;
        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

    }
}
