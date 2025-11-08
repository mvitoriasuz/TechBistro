import Image from 'next/image';
import Link from 'next/link';
import { Smartphone, ChefHat, CreditCard, BarChart } from 'lucide-react';

const Header = () => (
  <header className="relative w-full min-h-screen flex flex-col text-white">
    <div className="absolute inset-0 bg-hero-pattern bg-cover bg-center z-0"></div>
    
   <div className="absolute inset-0 bg-[url('/images/fundo_restaurante.jpg')] bg-cover bg-center z-0"></div>

    
    <div className="relative z-20 container mx-auto px-6 flex-grow flex flex-col">
      <nav className="w-full py-8 flex justify-between items-center">
        <div className="hidden md:flex w-full items-center">
          <div className="flex-1 flex justify-start gap-x-8 text-lg">
            <Link href="/" className="hover:opacity-80 transition-opacity duration-300">Início</Link>
            <Link href="/cardapio/39555038000166" className="hover:opacity-80 transition-opacity duration-300">Cardápio</Link>
          </div>
          <div className="flex-1"></div>
          <div className="flex-1 flex justify-end gap-x-8 text-lg">
            <Link href="#servicos" className="hover:opacity-80 transition-opacity duration-300">Nosso Serviço</Link>
            <Link href="#contato" className="hover:opacity-80 transition-opacity duration-300">Contato</Link>
          </div>
        </div>
        <div className="w-full flex justify-end md:hidden">
          <button className="text-white" aria-label="Abrir menu">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
          </button>
        </div>
      </nav>

      <div className="flex-grow flex flex-col items-center justify-center text-center -mt-20">
        <Image
          src="/logo.svg"
          alt="Logo Techbistro"
          width={140}
          height={140}
          priority 
        />
        <h1 className="text-4xl md:text-5xl font-bold tracking-[0.2em] mt-4 uppercase">
          Techbistro
        </h1>
      </div>
    </div>
  </header>
);

const FeatureCard = ({ icon: Icon, title, description }: { icon: React.ElementType, title: string, description: string }) => (
  <div className="flex flex-col items-center text-center p-4">
    <Icon className="w-16 h-16 text-brand-red mb-4" />
    <h3 className="text-lg font-semibold mb-2">{title}</h3>
    <p className="text-sm text-gray-600 dark:text-gray-400">
      {description}
    </p>
  </div>
);


export default function Home() {
  const features = [
    { icon: Smartphone, title: "Agilidade de pedido", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s." },
    { icon: ChefHat, title: "Integração da cozinha", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s." },
    { icon: CreditCard, title: "Pagamento", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s." },
    { icon: BarChart, title: "Verifique seu investimento", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s." },
  ];
  
  const servicesText = "Lorem Ipsum Is Simply Dummy Text Of The Printing And Typesetting Industry. Lorem Ipsum Has Been The Industry's Standard Dummy Text Ever since The 1500s.";

  return (
    <div className="font-sans antialiased">
      <Header />
      <main>
        <section id="vantagens" className="py-16 md:py-24 bg-white dark:bg-dark-bg">
          <div className="container mx-auto px-6">
            <h2 className="text-3xl font-bold text-center mb-12">
              VANTAGENS DE UTILIZAR O TECHBISTRO
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
              {features.map((feature, index) => (
                <FeatureCard key={index} {...feature} />
              ))}
            </div>
          </div>
        </section>

        <section id="servicos" className="py-16 md:py-24 bg-brand-red text-white">
          <div className="container mx-auto px-6 flex flex-col md:flex-row items-center gap-12">
            <div className="w-full md:w-1/3 flex justify-center">
              <div className="w-64 h-64 md:w-80 md:h-80 bg-white rounded-full flex items-center justify-center">
                 <span className="text-dark-text text-lg font-semibold">Imagem Aqui</span>
              </div>
            </div>
            <div className="w-full md:w-2/3 text-center md:text-left">
              <h2 className="text-3xl font-bold mb-6">Nossos Serviços</h2>
              <p className="leading-relaxed">
                {servicesText}
              </p>
            </div>
          </div>
        </section>
      </main>
      
      <footer className="bg-gray-100 dark:bg-black py-4">
        <div className="container mx-auto px-6 text-center text-gray-600 dark:text-gray-400 text-sm">
          <p>&copy; {new Date().getFullYear()} Techbistro. Todos os direitos reservados.</p>
        </div>
      </footer>
    </div>
  );
}

