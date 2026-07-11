# Thinking Craftsman Agentic Code Engineering Toolkit

These are my experiments and useful scripts related to Agentic Code Engineering. I am making these tools available to everyone. These scripts, agent skill files etc are for deploying "Agentic Code Engineering" in a project/team/company/startup. 

## Agent Skills
Current there are following skills defined based on [Agent Skills](https://agentskills.io) standard.

1. [Thinking Craftsman Skill](./agentskills/thinking-craftsman-skill)
This skill for reviewing code and generating code using the [Thinking Craftsman Code Review](https://thinkingcraftsman.in/pdfs/CodeReviewChecklist.pdf) guidelines. 
2. [Version Control Skill](./agentskills/version-control-skill/)
This skill is about using Version Control like git from your coding agents. This skill tries abstract the key version control practices. You just have to define which version control you are using in your agents.md. And Your coding agent will then invoke appropriate commands. Currently it support Git, Mercurial and Subversion. 
3. [Skill To Evaluate Skills](./agentskills/skill-eval-skill/)
This is Skill to evaluate other skill using your Coding Agent framework (e.g. Github Copilot or Claude Code). 
4. [Grill me](./agentskills/grill-me/)
This a skill based on mattpocock 'grill me' skill. It is about grilling you (user) about the a given document (especially source code document or design document)

Use the [`install.bat`](./agentskills/install.bat) or [`install.sh`](./agentskills/install.sh) scripts in [agentskills](./agentskills) folder to install the skill in your coding repository. The install script will detect which Coding Agent you are using and install the SKILL files in appropriate folder.

_NOTE_ : _All the above skills are undergoing changes and not fully stabilized yet. Feel free to use and share your feedback._

## Cookie Cutter for projects that use Coding Agents for development
Use the `agentic_cc` [cookie cutter](https://cookiecutter.readthedocs.io/en/stable/) template to generate project structure (default AGENTS.md, `.agents` folder and documents and source code folder structure) appropiate for use with Codig Agents.

- Install cookie cutter using uv.
```
uv tool install cookiecutter
```
- Change to the folder where you want to create a new project.
- Run the cookiecutter 
```
uvx cookiecutter <path to agentic_cc folder>.
```
Follow the instructions


# Shameless plug
If you want help in implementing these ideas, reach out to me (Nitin Bhide) at nitinbhide@thinkingcraftsman.in. 
