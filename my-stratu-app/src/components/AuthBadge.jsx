import { useState } from 'react';

function AuthBadge({ onAccessGranted }) {
    const [email, setEmail] = useState('');
    const [isApproved, setIsApproved] = useState(false);

    function handleSubmit(event) {
        event.preventDefault();
        setIsApproved(true);
        window.setTimeout(onAccessGranted, 1100);
    }

    return (
        <main className="auth-screen">
            <section className={`auth-card ${isApproved ? 'approved' : ''}`}>
                <div className="auth-tag">SECURE_AUTH // SYS-404</div>
                <div className="auth-heading">
                    <p className="eyebrow">STRATU SYSTEM</p>
                    <h1>Идентификация<br />дизайнера</h1>
                    <span>Визуальная матрица готова к подключению.</span>
                </div>
                <form onSubmit={handleSubmit}>
                    <label>КОД ИДЕНТИФИКАЦИИ (EMAIL)
                        <input type="email" required value={email} onChange={(event) => setEmail(event.target.value)} placeholder="DESIGNER@STRATU.APP" />
                    </label>
                    <label>ШИФР ДОСТУПА (ПАРОЛЬ)
                        <input type="password" required placeholder="••••••••••••" />
                    </label>
                    <button type="submit">ПОЛУЧИТЬ ДОПУСК К CANVAS <span>↗</span></button>
                </form>
                {isApproved && <div className="approval-stamp">APPROVED<div>ДОСТУП РАЗРЕШЕН</div></div>}
            </section>
            <p className="auth-footer">STRATU / PRIVATE VISUAL INDEX / 2026</p>
        </main>
    );
}

export default AuthBadge;
