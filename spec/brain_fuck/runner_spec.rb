RSpec.describe BrainFuck::Runner do
  let(:hello_world_program) do
    <<~CODE
      ++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.
      >---.
      +++++++.
      .
      +++.
      >>.
      <-.
      <.
      +++.
      ------.
      --------.
      >>+.
      >++.
    CODE
      .freeze
  end

  it 'runs program code' do
    expect { BrainFuck::Runner.new(hello_world_program).run }.to output("Hello World!\n").to_stdout
  end
end
