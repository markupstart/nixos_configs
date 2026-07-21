import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';

export default function Home(): JSX.Element {
    return (
        <Layout title="Hallscloud Handbook" description="Living documentation for hallscloud.org">
            <main className="home-shell">
                <section className="hero-card">
                    <p className="eyebrow">Hallscloud Handbook</p>
                    <h1>Operational docs for the hallscloud.org ecosystem.</h1>
                    <p className="hero-copy">
                        This handbook will replace the current HelpDocs content and become the
                        source of truth for guides, policies, and support workflows.
                    </p>
                    <div className="hero-actions">
                        <Link className="button button--primary" to="/docs/employee-handbook">
                            Read the handbook
                        </Link>
                        <Link className="button button--secondary" to="/docs/migration-plan">
                            View migration plan
                        </Link>
                    </div>
                </section>
            </main>
        </Layout>
    );
}