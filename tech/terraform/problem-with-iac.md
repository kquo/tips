### The Problem with Infrastructure-as-Code

It seems that all these tools are really just trying for compensate for an essential element that typical operating systems and cloud systems lack - a built-in version control system and process. For instance if Azure cloud kept track of every single change by versioning every single change, and offer the ability to safely go back to that previous version, then it could be argued that all these IaC systems would not be needed. Of course, I'm greatly simplifying this process, but I am speaking in very general terms, to point the essential role that modern IaC systems play currently.

If all OSes, cloud systems, and larger services offered built-in version control, most major IaC tools would go absolete.

There are many who would point out that modern IaC tools aren't just version controlling, points in time, the state of how a system is configured. They do much more than that, and that is indeed a valid objection.

But there are remedies to that objection, and well as others that may come upt. The build-in version control systems could also offer a host of other built-in features, such as template scaffolding, to address the standardization, the speedy automation, the complex orchestration, the cost management, and the overall security and compliance concerns. Public stake holders and industry players would benefit even more if there was an open standard for how each OS and cloud system did all this internally.

This is reminisicent of the early days of computer networking and the headaches of interfacing systems that ran with disimilar network protocols, until TCP/IP came along.

Granted, for some industry players this is probably not beneficial to their bottom line, but for consumers and most of the world, the benefits of having an open protocol for configurating, operating, and integrating hybrid systems would be ground-breaking.

The world needs a single, universal protocol for infrastructure management that mirrors the impact of TCP/IP for networking. An infrastructure management protocol that is built-in to every OS, cloud, or major service that offers the following:

1. Enhanced Collaboration and Interoperability: An open standard for infrastructure management and versioning would foster greater interoperability between different systems and clouds, making hybrid and multi-cloud strategies easier to implement and manage.

2. Reduced Complexity: By consolidating these capabilities into the infrastructure platforms themselves, it would reduce the learning curve and complexity associated with managing separate tools and scripts, leading to more accessible and manageable infrastructure management practices.

3. Innovation and Focus Shift: With foundational infrastructure management needs more directly addressed, organizations and tool developers could shift focus towards higher-level challenges and innovations, such as more advanced security practices, performance optimization, and cost-efficiency strategies.

4. Challenges in Adoption and Standardization: The path to such an integrated and standardized system would require significant cooperation among industry players, including cloud providers, operating system developers, and organizations. There would also be challenges related to legacy systems and the diversity of existing infrastructure setups.

5. Impact on Competition and Innovation: While standardization can drive efficiency and interoperability, it's also important to consider how it might affect competition and innovation within the industry. Differentiation in features and capabilities is one of the drivers of innovation, and a balance would need to be struck between standardization and maintaining a competitive, innovative landscape.

The development of such a protocol presents significant challenges, but the benefits of improved efficiency, security, and manageability in infrastructure management are compelling. The push towards such an ideal might come from a combination of technological advancements, industry collaboration, and shifts in market demand towards more streamlined and standardized infrastructure management solutions.

Are there any existing OS/cloud/systems companies or organizations currently looking for this IaC replacement protocol? Yes, evidently there are several initiatives and trends indicating a move towards greater interoperability and standardization. The most obvious one are Open Source IaC Tools such as Terraform and Ansible. Another is the Cloud Native Computing Foundation (CNCF) which hosts projects like Kubernetes, which, while not a direct IaC tool, has become a standard for container orchestration across different environments. There is also the IEEE 2302-2021 Standard for Intercloud Interoperability and Federation.

We will see what next few years bring us.
