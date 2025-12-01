import Link from 'next/link';
import Image from 'next/image';
import { ArrowLeft, ShieldCheck } from 'lucide-react';

export default function PoliticaPage() {
  return (
    <div className="min-h-screen bg-white font-sans selection:bg-[#C5A47E] selection:text-white">
      <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
        <div className="container mx-auto px-8 py-4 flex justify-between items-center">
          <Link href="/" className="flex items-center text-gray-400 hover:text-[#510006] transition-colors text-[10px] font-bold uppercase tracking-widest">
            <ArrowLeft className="w-4 h-4 mr-2" /> Voltar
          </Link>
          <div className="flex items-center gap-2">
            <Image src="/logo.svg" alt="Logo" width={24} height={24} />
            <span className="font-bold text-[#510006] uppercase tracking-widest text-xs">Legal</span>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-8 py-16 max-w-3xl">
        <div className="flex items-center gap-4 mb-10">
           <div className="w-12 h-12 bg-[#510006]/5 rounded-full flex items-center justify-center">
              <ShieldCheck className="w-6 h-6 text-[#510006]" />
           </div>
           <h1 className="text-2xl font-bold text-gray-900 uppercase tracking-wide">Política de Privacidade</h1>
        </div>
        
        <div className="space-y-12 text-gray-600 text-sm leading-loose text-justify border-l-2 border-gray-100 pl-8">
          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">1. Coleta de Dados</h2>
            <p>
              Ao utilizar nosso formulário de contato ou navegar em nosso site, podemos coletar informações básicas como nome, e-mail e telefone, estritamente para fins de retorno comercial solicitado por você.
            </p>
          </section>

          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">2. Uso das Informações</h2>
            <p>
              Utilizamos seus dados exclusivamente para: responder às suas dúvidas, apresentar propostas comerciais dos nossos planos e, ocasionalmente, enviar atualizações sobre novas funcionalidades, caso você opte por receber nossa newsletter.
            </p>
          </section>

          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">3. Proteção e Compartilhamento</h2>
            <p>
              Seus dados são armazenados em servidores seguros. A Techbistro não vende, aluga ou compartilha suas informações pessoais com terceiros para fins de marketing. O acesso aos dados é restrito à equipe necessária para o atendimento.
            </p>
          </section>
        </div>
      </main>

      <footer className="bg-[#f8f8f8] border-t border-gray-200 py-8 mt-12">
        <div className="container mx-auto px-8 text-center">
          <p className="text-[10px] uppercase tracking-widest text-gray-400">Techbistro &copy; Todos os direitos reservados.</p>
        </div>
      </footer>
    </div>
  );
}